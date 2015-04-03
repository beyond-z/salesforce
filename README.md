# salesforce
Place to keep code, docs, and other information related to our Salesforce integrations.

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
