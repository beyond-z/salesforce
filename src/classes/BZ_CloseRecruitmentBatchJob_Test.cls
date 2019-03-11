@isTest
public class BZ_CloseRecruitmentBatchJob_Test {
@testSetup 
    static void setup() {
        
        List<Contact> contactsToInsert = new List<Contact>();
        Contact campaignOwner = new Contact(FirstName='Test', LastName='CampaignOwner', OwnerId=userInfo.getUserId());
        contactsToInsert.add(campaignOwner);
        Contact contactWaitlist = new Contact(FirstName='Test', LastName='UserWaitlisted', Volunteer_Information__c='LC Pipeline');
        contactsToInsert.add(contactWaitlist);
        Contact contactOptedOutDropped = new Contact(FirstName='Test', LastName='UserOptedOutDropped', Volunteer_Information__c='LC Pipeline');
        contactsToInsert.add(contactOptedOutDropped);
        Contact contactOptedOutNoTime = new Contact(FirstName='Test', LastName='UserOptedOutNoTime', Volunteer_Information__c='LC Pipeline');
        contactsToInsert.add(contactOptedOutNoTime);
        Contact contactConfirmed = new Contact(FirstName='Test', LastName='UserConfirmed', Volunteer_Information__c='Current LC');
        contactsToInsert.add(contactConfirmed);
        insert contactsToInsert;
                        
        Campaign campaign = BZ_CampaignFactory_TEST.create(campaignOwner.OwnerId, 'Leadership Coaches');
        String campaignBeingClosedName = 'campaignBeingClosed';
        campaign.name=campaignBeingClosedName;
        String reinviteEmailTemplateName = 'reinviteEmailTemplate';
        campaign.Previous_Candidate_New_Invite__c = reinviteEmailTemplateName;
        campaign.ParentId='7014B00000166Or';
        campaign.Recruitment_Closed__c=True;
        campaign.ProcessType__c='Create';  
        campaign.StartDate=Date.today();
        campaign.EndDate=Date.today();
        insert campaign;
        // insert 100 CampaignMembers
        List<CampaignMember> campaignMembersToInsert = new List<CampaignMember>();
        CampaignMember cmWaitlist = new CampaignMember();
        cmWaitlist.CampaignId=campaign.ParentId;
        cmWaitlist.ContactId=contactWaitlist.Id;
        cmWaitlist.Candidate_Status__c = 'Waitlisted';
        cmWaitlist.Application_Status__c = 'Submitted';
        campaignMembersToInsert.add(cmWaitlist);
        
        CampaignMember cmOptedOutDropped = new CampaignMember();
        cmOptedOutDropped.CampaignId=campaign.ParentId;
        cmOptedOutDropped.ContactId=contactOptedOutDropped.Id;
        cmOptedOutDropped.Candidate_Status__c = 'Waitlisted';
        cmOptedOutDropped.Opted_Out_Reason__c = 'Dropped - During Program';
        cmOptedOutDropped.Application_Status__c = 'Submitted';
        campaignMembersToInsert.add(cmOptedOutDropped);
        
        CampaignMember cmOptedOutNoTime = new CampaignMember();
        cmOptedOutNoTime.CampaignId=campaign.ParentId;
        cmOptedOutNoTime.ContactId=contactOptedOutNoTime.Id;
        cmOptedOutNoTime.Candidate_Status__c = 'Waitlisted';
        cmOptedOutNoTime.Opted_Out_Reason__c = 'No Time';
        cmOptedOutNoTime.Application_Status__c = 'Submitted';
        campaignMembersToInsert.add(cmOptedOutNoTime);
        
        CampaignMember cmConfirmed = new CampaignMember();
        cmConfirmed.CampaignId=campaign.ParentId;
        cmConfirmed.ContactId=contactConfirmed.Id;
        cmConfirmed.Candidate_Status__c = 'Waitlisted';
        cmConfirmed.Application_Status__c = 'Submitted';
        campaignMembersToInsert.add(cmConfirmed);
        insert campaignMembersToInsert;
    }
    static testmethod void test() {        
        Test.startTest();
        String query = 'Select Id, Name,ParentId,Recruitment_Closed__c,ProcessType__c From Campaign WHERE Recruitment_Closed__c =true AND ProcessType__c=\'Create\'';
          
        BZ_CloseRecruitmentBatchJob uca = new BZ_CloseRecruitmentBatchJob(query);
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
     }
    
}
