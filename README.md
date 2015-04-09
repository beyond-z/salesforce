# Salesforce
Place to keep code, docs, and other information related to our Salesforce integrations.

# Configuration
## Configure Salesforce to talk to the Beyond Z Website
1. Login as a System Administrator
1. Under "Setup | Administer | Security Controls | Remote Site Settings" add these
   two remote sites
  * Name = "BZ Production SSL", Value = "https://www.beyondz.org"
  * Name = "BZ Production", Value = "http://www.beyondz.org"
1. Under "Setup | Build | Create | Apps | Connected Apps" create an app
   called "Beyond Z Production" with the following settings
  * DescriptionAllows the https://www.beyondz.org server to connect to Salesforcerce.
  * Permitted Users: All users may self-authorize
  * This application has permission to: Perform requests on your behalf at any time
  * This application has permission to: Full access
  * Refresh Token Policy: Refresh token is valid until revoked
  * Callback URL: https://www.beyondz.org/
  This will create the following two values that have to be set on the
BZ Org Website below:
  * Consumer Key: [[someLongConsumerKey]] 
  * Consumer Secret: [[someLongConsumerSecret]]
1. Under "Setup | Build | Develop | Custom Settings" create a setting
   with the following information:
  * Label: "BZ Settings"
  * Type: "List"
  * Visibility: "Protected"
  * API Name: "BZ_Settings__c"
  Add the following items to the BZ_Setting__c object's list:
  * Field Label - API Name - Data Type - Value
  * Magic token - magic_token__c - Text(64) -
    [[insertSomethingArbitrary]]
  * Site base URL - base_url__c - URL - https://www.beyondz.org
  Note that the setting is documented
[here](https://github.com/beyond-z/salesforce/blob/master/docs/settings.txt)
1. Create some credentials for the BZ Website to connect as admin.
   Assuming that you're logged in as [[adminUsername]] with password
[[adminPassword]], then on the
   upper right under "Your Name | My Settings | Personal | Reset My Security Token" click the "Reset Security Token" button to have it emailed to you.
   Let's call it [[adminSecurityToken]]

## Configure the Beyond Z Website to talk to Salesforce
1. Configure the following environment variables on the BZ Website using
   the values set in the Salesforce config settings above.  They are
also documented [here](https://github.com/beyond-z/beyondz-platform/blob/staging/env.sample) 
  * SALESFORCE_MAGIC_TOKEN: [[insertSomethingArbitrary]]
  * DATABASEDOTCOM_CLIENT_ID: [[someLongConsumerKey]]
  * DATABASEDOTCOM_CLIENT_SECRET: [[someLongConsumerSecret]]
  * SALESFORCE_USERNAME: [[adminUsername]]
  * SALESFORCE_PASSWORD: [[adminPassword]]
  * SALESFORCE_SECURITY_TOKEN: [[adminSecurityToken]]
  * SALESFORCE_HOST: login.salesforce.com
  * DEFAULT_LEAD_OWNER: [[staffEmailAddressOfDefaultLeadOwner]]

# Code Guidelines
All Beyond Z classes and triggers should start with BZ_ for their name.

All System.Debug() logs should be prefixed with the name of the parent
class or trigger so that we can filter on the current test.  E.g. 
```
trigger BZ_CampaignAssigned on CampaignMember (before insert) {
    System.Debug('BZ_CampaignAssigned: begin trigger');
    ...
    String myVar = blah;
    System.Debug('BZ_CampaignAssigned: some other info we want to log: '
+ myVar);
    ...
    
```

Commonly created test objects should be done through a helper/factory class.  
This way, when validation rules are added in the future you only have to change 
how you create the objects to conform to the rules in one spot.
```
private class BZ_SomeTestClass_TEST {
    Campaign c = CampaignFactory.create();
}
```


