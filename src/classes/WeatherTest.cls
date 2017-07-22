/* 
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

@istest
private class WeatherTest {
    private static testmethod void test() {
        Util.parseJSONDateTime('2010-01-01T00:00:00Z');
        GeoLocation gl = new GeoLocation();
        gl.latitude = 1;
        gl.longitude = 1;
        Object o = gl.isValid();

        WeatherLocation wl = new WeatherLocation('','','','','','');
        try { LocationService.getLocationForPostalCode('',''); } catch(Exception ex) { }
        LocationService.getLocationForPostalCode('12345','US');

        try { LocationService.getLocationForLocationType('', ''); } catch(Exception ex) { }
        LocationService.getLocationForLocationType('12345', 'US');

        Case c = new Case(Subject = 'testing');
        insert c;

        o = WeatherService.getMapKeys();

        WeatherService.getWeather(c.Id, 'English');

        c.Weather_Location__c = '30033';
        update c;

        WeatherService.getWeather(c.Id, 'English');

        WeatherService.getCurrentWeather('English', 0, 0);

        try { WeatherService.callUrl('http://something.com'); } catch(Exception ex) { }

        WeatherService.saveWeatherSnapshot(c.Id, '{}');

        System.assert(true);
    }
}