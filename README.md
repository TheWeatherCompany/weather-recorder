# The Weather Snapshot Unmanaged Component Guide

This component allows you to see weather conditions associated with a case and save them for future use. For example, when a customer reports that their car was damaged by hail, the customer service representative can save a snapshot of the current weather information and add it to the case. When the claims analyst reviews the case, they can see the weather information to verify that the damage could have been caused by hail.

The component adds the following weather data to case pages:
- Current weather conditions (temperature, chance of precipitation, and wind speed)
- Weather conditions for the past 24 hours

You can download the unmanaged component from [GitHub](https://github.com/TheWeatherCompany/snapshot/). To set it up, add the API key from your paid data package subscription from The Weather Company and customize it per your needs. Alternatively, you can use the code as a sample to understand how the API works and then build your own standalone app.

*Tip:* The component is shipped with mock data so you can try it out before you obtain an API key.

### Obtaining an API Key
By purchasing a data package and access key from The Weather Company, you can include any of the following data streams into the component:
- Weather Company Data for Salesforce – Core: Daily forecasts for the next 10 days, hourly forecasts for the next 48 hours, and historical weather conditions for the past 24 hours
- Weather Company Data for Salesforce – Enhanced: MMore precise and frequent weather observations, precipitation forecast, 15-minute forecast, and Nowcast
- Weather Company Data for Salesforce – Severe Weather:  Information on conditions including hail, lightning, and storms, and a power disruption index
- History on Demand: Historical data back to 2011, such as surface temperature, wind speed, wind direction, relative humidity, atmospheric pressure, and dew point

To purchase a Weather Company data package, [Weather Company Data for Salesforce](https://business.weather.com/products/weather-data-packages-salesforce).

## Installing and Configuring the Component
### System Requirements
The component is supported for Salesforce editions that include case management. Lightning Experience must be enabled. The component is not supported in Salesforce Classic. The component is supported on all browsers that are supported for Lightning Experience (see [Supported Browsers for Lightning Experience](https://help.salesforce.com/articleView?id=getstart_browsers_sfx.htm) in the Salesforce documentation).

### Setting Up the Component
*Prerequisite:* Prior to installation, ensure Lightning Experience is enabled (see [Enable Lightning Experience](https://help.salesforce.com/articleView?id=lex_enable_intro.htm)). 

To set up the component:
1. Get the component from [GitHub](https://github.com/TheWeatherCompany/snapshot/) and deploy it to Salesforce.
2. Add the Weather Location field and Weather Snapshots related list to the case page. The component displays the weather for the location specified in the Weather Location custom field. The Weather Snapshots related list displays all the snapshots that are associated with the case.
	1. In **Setup > Object Manager**, edit the page layout for the case object. 
	2. Add the Weather Location field to the case detail section. 
	3. Add the Weather Snapshots related list to the related lists section.
3. Grant users the required permissions for the component. In **Setup > Permission Sets**, assign users the WxSnap permission set (see [Assign a Permission Set to Multiple Users](https://developer.salesforce.com/docs/atlas.en-us.securityImplGuide.meta/securityImplGuide/perm_sets_mass_assign.htm)). 
4. Add the component to the case page by editing the page in the Lightning App Builder (see [Configure Lightning Experience Record Pages](https://help.salesforce.com/articleView?id=lightning_app_builder_customize_lex_pages.htm)).
	1. In the **Lightning Components** list, scroll down to the **Custom** section.
	2. Click **WxSnap** and drag the component to any place on the page.
	3. In the properties pane, select the default type of units to display. 
	4. Save and activate the updated page.

The component is now running with mock data.

### Enabling the component to display real data
After you obtain an API key (see [Weather Company Data for Salesforce](https://business.weather.com/products/weather-data-packages-salesforce)), enable the component to display real weather data.

To enable the component to display real data:
1. In Salesforce, create a CSP Trusted Site for https://<i></i>api.weather.com to access the Weather Company APIs (see [Create CSP Trusted Sites to Access Third-Party APIs](https://help.salesforce.com/articleView?id=csp_trusted_sites.htm)).
2. Enter the API key. In Custom Metadata Types, edit the SUN_Weather API record (see [Add or Edit Custom Metadata Records Declaratively](https://help.salesforce.com/articleView?id=custommetadatatypes_ui_populate.htm)). For the API Key field, specify the API key you received when you purchased the data package.  For the API User field, don’t specify a value. *Tip:* If the API Key field is not displayed for the API record, edit its page layout.
3. Disable the sample data response and activate the API calls to Weather.com. In the src/aura/WxSnap/WxSnap.cmp file, change the useMockup attribute to false. *Tip:* To improve performance, configure Salesforce to automatically add geocodes to all Account, Contact, and Lead records (see [Set Up Geocode Data Integration Rules](https://help.salesforce.com/articleView?id=data_dot_com_clean_add_geocode_information_to_all_records.htm)). The component then uses the geocode values instead of making API calls to determine the latitude and longitude for each address. 

  
### Extending the Component
You can extend the component by purchasing a data subscription and customizing the code to add more historical snapshot information, such as: 
- Additional 24 hour historical weather details like hail, snow, and ice (included in the Severe Weather package)
- Older historical data to create weather snapshots back to 2011. This data includes surface temperature, wind speed, wind direction, relative humidity, atmospheric pressure, and dew point (included in the History on Demand package)

For more details about how to extend the component, see the comments in the code.

### Restrictions
Snapshot shows data for locations in the U.S. and Canada only. The user interface is available in English only.

