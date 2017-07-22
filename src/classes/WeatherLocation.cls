/* 
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

public with sharing class WeatherLocation {
   @AuraEnabled public String city;
   @AuraEnabled public String state;
   @AuraEnabled public String postalCode;
   @AuraEnabled public String country;
   @AuraEnabled public String countryCode;
   @AuraEnabled public String adminDistrict;
   
   public WeatherLocation(String city, String state, String postalCode, String country, String countryCode, String adminDistrict) {
       this.city = city;
       this.state = state; 
       this.postalCode = postalCode;
       this.country = country;
       this.countryCode = countryCode;
       this.adminDistrict = adminDistrict;
   }   
}