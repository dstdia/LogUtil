/**
 * Test class LogDeleteSched Scheduling class
 *
 * @see         LogDeleteSched.cls
 *
 * @version     2016-06-14 kevin.kolditz@die-interaktiven.de      first version
 * 			    
 */	


@isTest
private class LogDeleteSchedTest {
	
	@isTest static void testSched() {
		Test.startTest();
		// Schedule the test job
		String sch = '0 0 8 11 12 ?';
		String jobId = System.schedule('LogDeleteSched', sch, new LogDeleteSched());

		// Verify the expressions are the same
		System.assert([SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId].size()!=0);
		Test.stopTest();
    }	
	
}