/* 
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

public with sharing class WeatherService {
    private static final String ENDPOINT = 'https://api.weather.com';
    private static Boolean key = true;
    @AuraEnabled
    public static WeatherDetailsResponse getWeather(Id recordId, String units) {
        if (units == 'Metric') units = 'm';
        else units = 'e';
        
        WeatherDetailsResponse resp = new WeatherDetailsResponse();
        try {
            if (!Case.sobjecttype.getDescribe().isAccessible()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Case.fields.Weather_Location__c.getDescribe().isAccessible()) throw new WeatherServiceException(Label.err_insufficient_access);
            Case c = [select Weather_Location__c from Case where Id = :recordId];

            String location = c.Weather_Location__c;
            if (String.isEmpty(location) || location.length() < 2) throw new WeatherServiceException(Label.err_unable_to_determine_location);
            location = location.toUpperCase();
            String countryCode = '';
            GeoLocation gl = new GeoLocation();
            if(location.substring(1,2).isNumeric()) {
                if (location.length() < 3) { 
                    countryCode='CA';
                } else if (location.length() < 5) {
                    location = location.substring(0,3);
                    countryCode = 'CA';  
                } else {
                    location = location.substring(0,5);
                    
                    if (location.substring(0, 1).isNumeric() != location.substring(1, 2).isNumeric()) {
                        countryCode = 'CA';
                        location = location.substring(0,3);
                    } else {
                        countryCode = 'US';
                    }
                }
                
                gl = LocationService.getLocationForPostalCode(location, countryCode);
		resp.location = new WeatherLocation(gl.city, gl.state, gl.postalCode, gl.country, gl.countryCode, gl.adminDistrict); 
                resp.location.postalCode = 'Postal Code ' + location;
                
            }
            else {
		List<String> wordsSpace = location.split(' ');
                List<String> wordsComma = location.split(',');
                if(!(wordsSpace.size()>=2 || wordsComma.size()>=2))
                    throw new WeatherServiceException(Label.err_unable_to_determine_location);    
                gl = LocationService.getLocationForLocationType(location, 'city'); 
		resp.location = new WeatherLocation(gl.city, gl.state, gl.postalCode, gl.country, gl.countryCode, gl.adminDistrict);             
            }              
            resp.conditions = getCurrentWeather(units,gl.latitude,gl.longitude);            
            resp.currentCondition = resp.conditions.get(0);
            resp.weatherURL = 'https://weather.com/redir?page=tenday&id=' + String.valueOf(gl.latitude) + ',' + String.valueOf(gl.longitude) + 
                '&par=salesforce_weatherrecorder&locale=en-US';
            resp.mapKeys = getMapKeys();
            resp.latitude = gl.latitude;
            resp.longitude = gl.longitude;
            resp.success = true;           
        } catch(Exception ex) {
            resp.hasPurchasedKey = key;
            resp.error = ex.getMessage();
            resp.success = false;
        }
        
        return resp;
    }
    
    @AuraEnabled
    public static WeatherSnapshotResponse saveWeatherSnapshot(Id caseId, String dataJson) {
        WeatherSnapshotResponse res = new WeatherSnapshotResponse();
        Savepoint sp = Database.setSavepoint();
        try {
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(dataJson);
            
            if (!Weather_Record__c.sobjecttype.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Weather_Record__c.fields.Case__c.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Weather_Record__c.fields.Date__c.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Weather_Record__c.fields.Description__c.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Weather_Record__c.fields.Geolocation__latitude__s.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Weather_Record__c.fields.Geolocation__longitude__s.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Weather_Record__c.fields.Temperature__c.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Weather_Record__c.fields.Wind_Direction__c.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);
            if (!Weather_Record__c.fields.Wind_Speed__c.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);          
            if (!Weather_Record__c.fields.Feels_Like_Temperature__c.getDescribe().isCreateable()) throw new WeatherServiceException(Label.err_insufficient_access);

            Weather_Record__c snapshot = new Weather_Record__c(
                Case__c = caseId,
                Date__c = Util.parseJSONDateTime((String)data.get('date')),
                Description__c = (String)data.get('description'),
                Geolocation__latitude__s = (Double)data.get('latitude'),
                Geolocation__longitude__s = (Double)data.get('longitude'),
                Temperature__c = (String)data.get('temperature'),
                Wind_Direction__c = (String)data.get('wind_direction'),
                Wind_Speed__c = (String)data.get('wind_speed'),              
                Feels_Like_Temperature__c = (String)data.get('feels_like_temp') 
            );
            insert snapshot;

            snapshot = [select Id, Name from Weather_Record__c where Id = :snapshot.Id];

            res.recordName = snapshot.Name;
            res.recordId = snapshot.Id;
            res.success = true;
        } catch(Exception ex) {
            Database.rollback(sp);
            res.error = ex.getMessage();
            res.success = false;
        }
        return res;
    }
    
    public static Map<String, Object> callUrl(String url) {
        API__mdt apiInfo;
        try {
         apiInfo = APIHelper.getAPI_SUNWeather();
        }
        catch(Exception e){
            key = false;
            throw new WeatherServiceException(e.getMessage());            
        }
        
        if (url.indexOf('?') < 0) url += '?';
        url += '&hours=23&apiKey=' + apiInfo.API_Key__c;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT + url);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        String body = null;
        if (Test.isRunningTest()) {
            body = '{"errors":[{"error":{"message":""}}]}';
        } else {
            HttpResponse response = http.send(request);
            body = response.getBody();
        }
        
        Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> errors = (List<Object>)resp.get('errors');
        if (errors != null && !errors.isEmpty()) {
            Map<String, Object> error = (Map<String, Object>)errors[0];
            error = (Map<String, Object>)error.get('error');           
            if(!(((String)error.get('message')).equals('Invalid apiKey.')))
            	throw new WeatherAPIException((String)error.get('code'), (String)error.get('message'));
            else {
                key = false;
                throw new WeatherAPIException((String)error.get('code'), Label.err_noAPI_Key); 
            }
        }
        
        return resp;
    }
    
    public static List<WeatherCondition> getCurrentWeather(String units, Decimal latitude, Decimal longitude) {
        Map<String, Object> resp = null;
        
        if (!Test.isRunningTest()) {
            resp = callUrl('/v1/geocode/' + latitude + '/'+longitude +'/observations/timeseries.json?units=' + units);
        } else {
            resp = new Map<String, Object> { 'observations' => new List<Map<String, Object>> { new Map<String, Object> { 'valid_time_gmt' => 1494946380, 'imperial' => new Map<String, Object> {}, 'metric' => new Map<String, object> {}} } };
		}

        //resp = (Map<String, Object>)resp.get('observation');
        List<Object> obs = (List<Object>) resp.get('observations');
        
        if (obs.size() == 0) throw new WeatherServiceException(System.Label.err_invalid_api_response_received);
        
        List<WeatherCondition> weatherData = new List<WeatherCondition>();
        for(Integer i=obs.size()-1;i>=0;i--) {
            resp = (Map<String, Object>) obs.get(i);
            WeatherCondition ret = new WeatherCondition();
            ret.iconCode = (resp.get('wx_icon') == null) ? 'na' : '' + resp.get('wx_icon');
            ret.phrase = (resp.get('wx_phrase')==null) ? 'N/A' : ''+ resp.get('wx_phrase');
            ret.dayInd = '' + resp.get('day_ind');
            ret.windSpeed = (resp.get('wspd')==null) ? 'N/A' : '' + resp.get('wspd');
            ret.windDirectionCardinal = (resp.get('wdir_cardinal')==null) ? 'N/A' : '' + resp.get('wdir_cardinal');            
            Integer unixTime = (Integer)resp.get('valid_time_gmt');
            DateTime dateInstance = Datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0);
            DateTime localTime = DateTime.parse(dateInstance.addSeconds(unixTime).format());
            ret.asOf = localTime;
            ret.asOfStr = dateInstance.addSeconds(unixTime).formatGMT('MM/dd/yyyy HH:mm a');
            ret.temp = (resp.get('temp')==null) ? 'N/A' : '' + resp.get('temp');
            ret.feelsLikeTemp = (resp.get('feels_like')==null) ? 'N/A' : '' + resp.get('feels_like');
            weatherData.add(ret);
        }
        
        return weatherData;
    }
    
    public static MapKeys getMapKeys() {
        MapKeys mapKeys = new MapKeys();
        
        API__mdt sunApiInfo = APIHelper.getAPI('SUN Weather');
        //  API__mdt mapboxApiInfo = APIHelper.getAPI('Mapbox');
        
        mapKeys.sun = sunApiInfo.API_Key__c;
        //    mapKeys.mapbox = mapboxApiInfo.API_Key__c;
        
        return mapKeys;
    }
    
    public class WeatherSnapshotResponse {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public String error;
        @AuraEnabled public Boolean success;        
    }
    
    public class WeatherDetailsResponse {
        @AuraEnabled public List<WeatherCondition> conditions;
        @AuraEnabled public WeatherCondition currentCondition;
        @AuraEnabled public WeatherLocation location;
        @AuraEnabled public String weatherURL;               
        @AuraEnabled public MapKeys mapKeys;
        @AuraEnabled public Decimal latitude;
        @AuraEnabled public Decimal longitude;
	@AuraEnabled public Boolean hasPurchasedKey;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String error;
        @AuraEnabled public Boolean success;
    }
    
    public class MapKeys {
        @AuraEnabled public String sun;
        @AuraEnabled public String mapbox;
    }
    
    public class WeatherServiceException extends Exception {}
    public class WeatherAPIException extends Exception {
        public String code;
        public WeatherAPIException(String code, String message) {
            this(message);
            this.code = code;
        }
    }
}
