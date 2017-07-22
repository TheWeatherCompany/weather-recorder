/*
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

({
	init: function(component) {
        /** To support unmanaged */
        var isMockup = component.get('v.useMockup')
        if (isMockup){
            this.loadMockup(component);
        }
        else {
	        this.loadWeather(component);
        }
    },

    loadMockup : function(component) {
        if (!component.get('v.domLoaded')) return;
		component.set('v.weatherLoading', true);
        component.set('v.weatherLocation',{city: $A.get("$Label.c.mock_city"),state: $A.get("$Label.c.mock_state"), countryCode:'US'});
        var currentDate = new Date();
        var currentMock = {asOf: currentDate.toISOString(), asOfTime: $A.localizationService.formatDate(currentDate,"h:mm a"), dayInd: 'N', feelsLikeTemp:'70',iconCode:'37',phrase:'Fair / Rain',temp:'80',windDirectionCardinal:'CALM',windSpeed:'0'};
        component.set('v.currentConditions', currentMock);
	component.set('v.latitude', 38.902);
        component.set('v.longitude', -77.040);

        var d1 = new Date();
        d1.setHours(d1.getHours() - 2);
        var d2 = new Date();
        d2.setHours(d2.getHours() - 4);
        var d3 = new Date();
        d3.setHours(d3.getHours() - 6);

        var initialDate = $A.localizationService.formatDate(currentDate.asOf,"d");
        var mocData =  [
        	currentMock,
        	{asOf: d1.toISOString(), asOfTime: $A.localizationService.formatDate(d1,"h:mm a"), dayInd: 'N', feelsLikeTemp:'50',iconCode:'39',phrase:'Rain',temp:'40',windDirectionCardinal:'W',windSpeed:'22'},
        	{asOf: d2.toISOString(), asOfTime: $A.localizationService.formatDate(d2,"h:mm a"), dayInd: 'N', feelsLikeTemp:'70',iconCode:'30',phrase:'Partly Cloudy',temp:'60',windDirectionCardinal:'WNW',windSpeed:'23'},
        	{asOf: d3.toISOString(), asOfTime: $A.localizationService.formatDate(d3,"h:mm a"), dayInd: 'N', feelsLikeTemp:'30',iconCode:'23',phrase:'Windy',temp:'20',windDirectionCardinal:'N',windSpeed:'21'}];
        component.set('v.conditions',mocData);
        component.set('v.labelDropDown', 'Today ' + $A.localizationService.formatDate(currentDate.asOf,"h:mm a"));
        component.set('v.todayDate','Today, ' + $A.localizationService.formatDate(currentDate.asOf,"MMM d"));

        for(var i=0; i<mocData.length; i++) {
            var date = $A.localizationService.formatDate(mocData[i].asOf,"d");
            if(date!=initialDate && component.get('v.indexToChangeDate')==-1) {
                component.set('v.indexToChangeDate',i);
                component.set('v.yesterdayDate',$A.localizationService.formatDate(mocData[i].asOf,"MMMM d"));
            }
        }
        component.set('v.weatherLoading', false);
        component.set('v.weatherLoaded', true);
	},

    loadWeather : function(component) {
        if (!component.get('v.domLoaded')) return;

        var action = component.get("c.getWeather");
        component.set('v.weatherLoading', true);

        action.setParams({
            recordId: component.get('v.recordId'),
            units: component.get('v.units')
        });
        action.setCallback(this, function(a) {
            var ret = a.getReturnValue();
            var weatherLoaded = false;
            var errorMessage = '';

            if (ret) {
                if (ret.success) {
                    component.set('v.currentConditions', ret.currentCondition);
                    component.set('v.conditions', ret.conditions);
                    var initialDate = $A.localizationService.formatDate(ret.conditions[0].asOf,"d");
                    component.set('v.todayDate','Today, ' + $A.localizationService.formatDate(ret.conditions[0].asOf,"MMM d"));
                    for(var i=0;i<ret.conditions.length;i++) {
                        var date = $A.localizationService.formatDate(ret.conditions[i].asOf,"d");
                        if(date!=initialDate && component.get('v.indexToChangeDate')==-1) {
                            component.set('v.indexToChangeDate',i);
                            component.set('v.yesterdayDate',$A.localizationService.formatDate(ret.conditions[i].asOf,"MMMM d"));
                        }
                        ret.conditions[i].asOfTime = $A.localizationService.formatDate(ret.conditions[i].asOf,"h:mm a");
                    }
                    component.set('v.labelDropDown', 'Today ' + $A.localizationService.formatDate(ret.conditions[0].asOf,"h:mm a"));
                    component.set('v.weatherLocation',ret.location);
                    component.set('v.weatherURL', ret.weatherURL);
                    component.set('v.latitude', ret.latitude);
                    component.set('v.longitude', ret.longitude);

                    if(ret.severeAlert=='W') {
                        component.set('v.severeAlertImage','/alert-warning.svg');
                    }
                    else if(ret.severeAlert=='A') {
                        component.set('v.severeAlertImage','/alert-watch.svg');
                    }
                        else if(ret.severeAlert=='Y') {
                            component.set('v.severeAlertImage','/alert-advisory.svg');
                        }
                            else if(ret.severeAlert=='S') {
                                component.set('v.severeAlertImage','/alert-statement.svg');
                            }
                    weatherLoaded = true;
                } else {
		    component.set('v.hasPurchasedKey', ret.hasPurchasedKey);
                    errorMessage = ret.error;
                }
            } else {
                errorMessage = a.getError()[0].message;
            }

            component.set('v.errorMessage', errorMessage);
            component.set('v.weatherLoading', false);
            component.set('v.weatherLoaded', weatherLoaded);

        })
        $A.enqueueAction(action);
    }
})
