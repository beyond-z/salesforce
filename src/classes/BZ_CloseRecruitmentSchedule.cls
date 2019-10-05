/**
 * Handles BZ_CloseRecruitmentBatchJob actions of the campaign related CampaignMembers processing for schedule batch jobs.
 * To invoke Apex classes to run at specific times, first implement the Schedulable interface for the class. 
 * Then, schedule an instance of the class to run at a specific time.
 */
global class BZ_CloseRecruitmentSchedule implements Schedulable {

    global void execute(SchedulableContext context) {
        String campaignObjectQueryString = 'Select Id, Name,ParentId,Recruitment_Closed__c,ProcessType__c From Campaign WHERE'
            							   + 'Recruitment_Closed__c =true AND ProcessType__c=\'Create\'';
        //Calling the BZ_CloseRecruitmentBatchJob for processing the campaign members.   
        BZ_CloseRecruitmentBatchJob batch = new BZ_CloseRecruitmentBatchJob(campaignObjectQueryString); 
        database.executebatch(batch);
        // Cron EXP for hourly schedule  
        System.schedule('Job Startes per every one hour :', '0 0 * * * ?' , new BZ_CloseRecruitmentSchedule() );
     }
}
