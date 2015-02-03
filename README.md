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
