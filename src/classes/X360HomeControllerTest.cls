@isTest
public class X360HomeControllerTest {
	static TestMethod void testGetTopToSumContributedScore(){
		PageReference pageRef = Page.X360Home;
		
		Test.setCurrentPage(pageRef);
		Test.startTest();
///////////////////////////////

		Contributed_Score__c[] scoresForContact = new Contributed_Score__c[]{};
		Measure__c measure = new Measure__c(name='measure', Description__c='measureDesc');
		Rule__c rule1 = new Rule__c(name='rule1', description__c = 'desc1');
        Rule__c rule2 = new Rule__c(name='rule2', description__c = 'desc2');
        Contact ct = new Contact(lastname='testing',firstname='apex');
        insert measure;
        insert rule1;
        insert rule2;
        insert ct;
        
        Contributed_Score__c cs = new Contributed_Score__c(contact_id__c = ct.Id,
         measure_id__c = measure.Id, rule__c = rule1.Id, score__c = 69);
         
        Contributed_Score__c cs2 = new Contributed_Score__c(contact_id__c = ct.Id,
         measure_id__c = measure.Id, rule__c = rule2.Id, score__c = 77);
		
        insert cs;
        insert cs2;
///////////////////////////////
        Test.stopTest();
		
		X360HomeController controller = new X360HomeController();
		
		System.assertEquals(controller.topContributedList.size(), 1);
		System.assertEquals(controller.topExpectedList.size(), 0);
		System.assertEquals(controller.topEarnedList.size(), 0);
		System.assertEquals(controller.topExpectedAccountList.size(), 0);
		System.assertEquals(controller.topEarnedAccountList.size(), 0);
		
		System.assertEquals(controller.topContributedList[0].Score, 69+77);
		
		
	}
	static TestMethod void testGetTopToSumEarnedScore(){
		PageReference pageRef = Page.X360Home;
		
		Test.setCurrentPage(pageRef);
		Test.startTest();
///////////////////////////////
		Contributed_Score__c[] scoresForContact = new Contributed_Score__c[]{};
		Measure__c measure = new Measure__c(name='measure', Description__c='measureDesc');
		Rule__c rule1 = new Rule__c(name='rule1', description__c = 'desc1');
        Rule__c rule2 = new Rule__c(name='rule2', description__c = 'desc2');
        Contact ct = new Contact(lastname='testing',firstname='apex');
        insert measure;
        insert rule1;
        insert rule2;
        insert ct;
        
		Earned_Score__c es = new Earned_Score__c(contact_id__c = ct.Id,
         measure_id__c = measure.Id, rule__c = rule1.Id, score__c = 50);
         
        Earned_Score__c es2 = new Earned_Score__c(contact_id__c = ct.Id,
         measure_id__c = measure.Id, rule__c = rule2.Id, score__c = 50);
		
        insert es;
        insert es2;
///////////////////////////////
        Test.stopTest();
		
		X360HomeController controller = new X360HomeController();
		
		System.assertEquals(controller.topContributedList.size(), 0);
		System.assertEquals(controller.topExpectedList.size(), 0);
		System.assertEquals(controller.topEarnedList.size(), 1);
		System.assertEquals(controller.topExpectedAccountList.size(), 0);
		System.assertEquals(controller.topEarnedAccountList.size(), 0);
		
		System.assertEquals(controller.topEarnedList[0].Score, 100);
		
		
	}
	static TestMethod void testGetTopToSumAccountScore(){
		PageReference pageRef = Page.X360Home;
		
		Test.setCurrentPage(pageRef);
		Test.startTest();
///////////////////////////////
		Account_Expected_Score__c[] scoresForContact = new Account_Expected_Score__c[]{};
		Measure__c measure = new Measure__c(name='measure', Description__c='measureDesc');
		Rule__c rule1 = new Rule__c(name='rule1', description__c = 'desc1');
        Rule__c rule2 = new Rule__c(name='rule2', description__c = 'desc2');
        Account ct = new Account(name='testing');
        Account ct2 = new Account(name='testing2');
        insert measure;
        insert rule1;
        insert rule2;
        insert ct;
        insert ct2;
        
		Account_Expected_Score__c es = new Account_Expected_Score__c(account__c = ct.Id,
         measure_id__c = measure.Id, rule__c = rule1.Id, score__c = 51);
         
        Account_Expected_Score__c es2 = new Account_Expected_Score__c(account__c = ct.Id,
         measure_id__c = measure.Id, rule__c = rule2.Id, score__c = 49);
		
        insert es;
        insert es2;
///////////////////////////////
        Test.stopTest();
		
		X360HomeController controller = new X360HomeController();
		
		System.assertEquals(controller.topContributedList.size(), 0);
		System.assertEquals(controller.topExpectedList.size(), 0);
		System.assertEquals(controller.topEarnedList.size(), 0);
		System.assertEquals(controller.topExpectedAccountList.size(), 1);
		System.assertEquals(controller.topEarnedAccountList.size(), 0);
		
		System.assertEquals(controller.topExpectedAccountList[0].Score, 100);
		System.assertEquals(controller.topExpectedAccountList[0].Name, ct.Name);
		
		
	}
}