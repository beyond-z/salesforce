@isTest
Private class BZ_CloseRecruitmentSchedule_Test {
// Dummy CRON expression: midnight on Feb 21.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 21 2 ? 2019';
    static testmethod void testScheduledJob() {
        Test.startTest();
        // Schedule the test job
        //String jobId = System.schedule('ScheduledApexTest',CRON_EXP);
         BZ_CloseRecruitmentSchedule schedule = new BZ_CloseRecruitmentSchedule();
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch = '20 5 4 10 2 ?';
		String jobID = System.schedule('CampaignMembers', sch, schedule);    
        Test.stopTest();
    }
}