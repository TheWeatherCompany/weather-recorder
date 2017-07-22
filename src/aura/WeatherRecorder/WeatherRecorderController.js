/* 
Copyright 2017 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
*/

({
	doInit : function(component, event, helper) {
		helper.init(component);
    },

    reloadWeather: function(component, event, helper) {
    	helper.init(component);
    },

    saveSnapshot: function(component, event, helper) {
        var action = component.get("c.saveWeatherSnapshot");
        var currentConditions = component.get('v.currentConditions');

        var dataJson = JSON.stringify({
            date: component.get('v.currentConditions').asOf,
            description: currentConditions.phrase,
            latitude: component.get('v.latitude'),
            longitude: component.get('v.longitude'),
            temperature: currentConditions.temp,
            wind_direction: currentConditions.windDirectionCardinal,
            wind_speed: currentConditions.windSpeed,
            feels_like_temp: currentConditions.feelsLikeTemp,
        });
        action.setParams({
            caseId: component.get('v.recordId'),
            dataJson: dataJson
        });
        action.setCallback(this, function(a) {
            var ret = a.getReturnValue();
            var errorMessage = '';

            if (ret) {
                if (ret.success) {
                    $A.get('e.force:refreshView').fire();

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'success',
                        "message": "...",
                        "messageTemplate": $A.get("$Label.c.msg_snapshot_saved_success_message"),
                        "messageTemplateData": [{
                            url: '/' + ret.recordId,
                            label: ret.recordName
                        }],
                        "duration": 10000
    				});
                    toastEvent.fire();
                } else {
                    errorMessage = ret.error;
                }
            } else {
                errorMessage = a.getError()[0].message;
            }

            component.set('v.errorMessage', errorMessage);
        })
        $A.enqueueAction(action);
    },
    handleAction: function(component, event, helper) {
        //var sel = event.getParam("value");
        var eve = event.currentTarget;
        var sel = eve.getAttribute('data-index');
        if($A.localizationService.formatDate(component.get('v.conditions')[0].asOf,"d") == $A.localizationService.formatDate(component.get('v.conditions')[sel].asOf,"d"))
			component.set('v.labelDropDown', 'Today ' + $A.localizationService.formatDate(component.get('v.conditions')[sel].asOf,"h:mm a"));
        else
            component.set('v.labelDropDown',$A.localizationService.formatDate(component.get('v.conditions')[sel].asOf,"MMM d h:mm a"));
        var cmpTarget = component.find('changeIt');
        $A.util.removeClass(cmpTarget, 'slds-is-open');
        component.set('v.currentConditions',component.get('v.conditions')[sel]);

    },
    updateDropDown: function(component, event, helper) {
        var cmpTarget = component.find('changeIt');
        if(cmpTarget.getElement().classList.contains('slds-is-open'))
            $A.util.removeClass(cmpTarget, 'slds-is-open');
        else
        	$A.util.addClass(cmpTarget, 'slds-is-open');
    }
})
