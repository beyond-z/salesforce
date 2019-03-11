/**
* Handles BZ_CloseRecruitmentController actions of the campaign related CampaignMembers processing for large records.
*/
global class BZ_CloseRecruitmentBatchJob implements Database.Batchable<sObject> {
    global final String Query;
    // The list of campaigns object types to create.  E.g. CampaignMember
    global List<Campaign> campaignsList=new List<Campaign>();
    global List<Id> memberContactIdsNotToPurge = new List<Id>();
    /**
* Initialize the constructor for use campaign query.
*/
    global BZ_CloseRecruitmentBatchJob(string campaignQuery)
    {
        Query=campaignQuery;
    }
    /**
* Used to collect the records or objects to be passed to the interface method execute for processing.
*/
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        return Database.getQueryLocator(query);
    }
    /**
* Processing the campaign related campaignMembers
* Ex.getting the all Waitlisted Campaign Members from old Campaign and inserting to new Campaign.
* process each batch of records
*/
    global void execute( Database.BatchableContext batchableContext,List<Campaign> campaigns)
    {
        List<Id> newCampaignMemberContactIds = new List<Id>();
        Set<Id> oldCampaignIds = new Set<Id>();
        Set<Id> newCampaignIds = new Set<Id>();
        List<Campaign> updtaedCampaignList = new List<Campaign>();
        List<Contact> contactListNewCampaignMembers=new List<Contact>();
        List<CampaignMember> membersNotPurged  =new List<CampaignMember>();
        List<CampaignMember> newCampaignMembers = new List<CampaignMember>();
        Map<Id, Id> contactIdMap = new Map<Id,Id>();
        Map<Id, Id> campaignIdMap = new Map<Id,Id>();
        
        //Check if campaign members List is not null and size is greater than zero
        if(campaigns!=null && campaigns.size()>0){
            system.debug('campaigns list--'+campaigns.size());
            system.debug('campaigns list--'+campaigns);
            for(Campaign camp : campaigns)
            {
                // Checking the campaign ProcessType__c and Recruitment_Closed__c
                if(camp.Recruitment_Closed__c=true && camp.ProcessType__c=='Create'){
                    oldCampaignIds.add(camp.ParentId);
                    newCampaignIds.add(camp.Id);
                    //cloning the campaigns to new list
                    campaignsList=campaigns.clone();
                    camp.ProcessType__c='Clone';
                    //updating the campaign with ProcessType__c='Clone' 
                    updtaedCampaignList.add(camp);
                    //Mapping ID of closed recuritment campaign with the Id of the new campaign
                    campaignIdMap.put(camp.ParentId, camp.Id);
                }
            }
        }
        // Getting the list of campaign Members where Candidate_Status__c = 'Waitlisted' & Candidate_Status__c = 'Opted Out' from old campaign 
        if (oldCampaignIds != null && !oldCampaignIds.isEmpty()){
            membersNotPurged  = [SELECT Id, ContactId, CampaignId, Candidate_Status__c, Opted_Out_Reason__c,
                                 Apply_Button_Enabled__c,Section_Name_In_LMS__c,
                                 Selected_Timeslot__c,Application_Status__c 
                                 FROM CampaignMember 
                                 WHERE CampaignId IN:oldCampaignIds AND
                                 (Candidate_Status__c = 'Waitlisted' OR
                                  (
                                      Candidate_Status__c = 'Opted Out' AND 
                                      (
                                          Opted_Out_Reason__c = 'No Time' OR
                                          Opted_Out_Reason__c = 'No Available Units' OR
                                          Opted_Out_Reason__c = 'No Interest Right Now'
                                      )
                                  )
                                 )];
        }
        if (membersNotPurged  != null && !membersNotPurged .isEmpty()){
            system.debug('membersNotPurged  list--'+membersNotPurged .size());
            for (CampaignMember campaignMem : membersNotPurged ){
                memberContactIdsNotToPurge.add(campaignMem.ContactId);
                newCampaignMemberContactIds.add(campaignMem.ContactId);
                //Mapping a campaign's member contact with it's current campaign Id 
                contactIdMap.put(campaignMem.ContactId, campaignMem.CampaignId);                      
            }
            
            // Getting Contacts from Waitlisted Campaign Memberes
            contactListNewCampaignMembers = [SELECT Id, FirstName, LastName, Phone, Anticipated_Graduation__c, 
                                             Started_College__c,Accepts_Text__c,Industry__c, Company__c, Sourcing_Info__c,
                                             Grad_University__c, Graduate_Year__c, Grad_Degree__c, Undergrad_University__c,
                                             Middle_Name__c, Hometown__c, Digital_Footprint_2__c, Digital_Footprint__c,
                                             African_American__c, Asian_American__c, Latino__c,
                                             Native_Alaskan__c, Native_American__c, Native_Hawaiian__c,
                                             Pacific_Islander__c, White__c, Multi_Ethnic__c, Other_Race__c,
                                             Identify_As_First_Gen__c, Identify_As_Low_Income__c,
                                             Identify_As_Person_Of_Color__c, Pell_Grant_Recipient__c
                                             FROM Contact
                                             WHERE Id IN :newCampaignMemberContactIds];
            System.debug('contactListNewCampaignMembers --->' + contactListNewCampaignMembers.size());
            
            //Creating new campaign members from contacts
            for(Contact contact : contactListNewCampaignMembers) {
                //Creating new campaign members;
                Id previousCampaignId = contactIdMap.get(contact.Id);
                Id newCampaignId = campaignIdMap.get(previousCampaignId);
                System.debug('BZ_CloseRecruitmentBatchJob: previousCampaignId' + previousCampaignId);
                System.debug('BZ_CloseRecruitmentBatchJob: newCampaignId' + newCampaignId);
                
                CampaignMember campaignMember = new CampaignMember();
                campaignMember.CampaignId = newCampaignId;              		
                campaignMember.ContactId = contact.Id;
                campaignMember.Started_College__c = contact.Started_College__c;
                campaignMember.Anticipated_Graduation__c = contact.Anticipated_Graduation__c;
                campaignMember.Application_Decision_Sent__c = false;
                if (campaignMember.Application_Status__c == 'Submitted'){
                    campaignMember.Application_Status__c = 'Started';            
                }
                campaignMember.Apply_Button_Enabled__c = true;
                campaignMember.Section_Name_In_LMS__c = null;
                campaignMember.Selected_Timeslot__c = null;
                campaignMember.Candidate_Status__c = null;
                campaignMember.Accepts_Text__c=contact.Accepts_Text__c;
                campaignMember.Industry__c = contact.Industry__c;
                campaignMember.Company__c = contact.Company__c;
                campaignMember.Sourcing_Info__c = contact.Sourcing_Info__c;
                campaignMember.Grad_University__c = contact.Grad_University__c;
                campaignMember.Graduate_Year__c = contact.Graduate_Year__c;
                campaignMember.Grad_Degree__c = contact.Grad_Degree__c;
                campaignMember.Undergrad_University__c = contact.Undergrad_University__c;
                campaignMember.Middle_Name__c = contact.Middle_Name__c;
                campaignMember.Hometown__c = contact.Hometown__c;
                campaignMember.Digital_Footprint_2__c = contact.Digital_Footprint_2__c;
                campaignMember.Digital_Footprint__c = contact.Digital_Footprint__c;
                campaignMember.African_American__c = contact.African_American__c;
                campaignMember.Asian_American__c = contact.Asian_American__c;
                campaignMember.Latino__c = contact.Latino__c;
                campaignMember.Native_Alaskan__c = contact.Native_Alaskan__c;
                campaignMember.Native_American__c = contact.Native_American__c;
                campaignMember.Native_Hawaiian__c = contact.Native_Hawaiian__c;
                campaignMember.Pacific_Islander__c = contact.Pacific_Islander__c;
                campaignMember.White__c = contact.White__c;
                campaignMember.Multi_Ethnic__c = contact.Multi_Ethnic__c;
                campaignMember.Other_Race__c = contact.Other_Race__c;
                campaignMember.Identify_As_First_Gen__c = contact.Identify_As_First_Gen__c;
                campaignMember.Identify_As_Low_Income__c = contact.Identify_As_Low_Income__c;
                campaignMember.Identify_As_Person_Of_Color__c = contact.Identify_As_Person_Of_Color__c;
                campaignMember.Pell_Grant_Recipient__c = contact.Pell_Grant_Recipient__c;
                newCampaignMembers.add(campaignMember);
            }
            
        }
        
        try {
            //Check if campaign members List is null and size
            if (newCampaignMembers != null && newCampaignMembers.size()>0) {
                
                system.debug('newCampaignMembers list--'+newCampaignMembers.size()); 
                //Inserting the list of new campaign members
                insert newCampaignMembers;
                System.debug('List Size ' + newCampaignMembers.size());
            }
            if (updtaedCampaignList != null && updtaedCampaignList.size()>0) {
                system.debug('updtaedCampaignList --'+updtaedCampaignList.size());    
                update updtaedCampaignList;
                System.debug('List Size ' + updtaedCampaignList.size()); 
            }
        } catch(Exception ex) {
            System.debug('Inserting Campaign Members Error : '+ex.getMessage());}
    }
    /**
* Calling the mapping class and passing oldCampaignId,newCampaignId,list of membersNotToPurge
* Execute any post-processing operations
*/
    global void finish(Database.BatchableContext batchableContext){
        //Check if campaign List is not null and size is greater than zero
        if(campaignsList!=null & campaignsList.size()>0)
        {       
            System.debug('campaignsList size -- ' + campaignsList.size()); 
            System.debug('campaignsList Data -- ' + campaignsList); 
            for(Campaign camp:campaignsList){
                if(camp.Id!=null & camp.ParentId!=null){
                    if(memberContactIdsNotToPurge!=null & memberContactIdsNotToPurge.size()>0)
                    {
                        //Calling the mapping class and passing oldCampaignId,newCampaignId,list of membersNotToPurge
                        BZ_Notifications.changeCampaigns(memberContactIdsNotToPurge, camp.ParentId, camp.Id);
                    }
                }
            }
        }
        
    }     
    
    
}
