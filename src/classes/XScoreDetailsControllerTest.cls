@isTest
public class XScoreDetailsControllerTest {
	static TestMethod void TestControllerWithIncorrectParam(){
		PageReference pageRef = Page.XScoreDetails;
		
		Test.setCurrentPage(pageRef);
		
		ApexPages.currentPage().getParameters().put('sc', 'x');
		
		XScoreDetailsController controller = new XScoreDetailsController();
		
		System.assertEquals(controller.scoreDetails, null);
		
		
	}
	
	static TestMethod void TestControllerWithCorrectContactParam(){
		
		PageReference pageRef = Page.XScoreDetails;
		
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
        //name={!o.Name}&sc=E&cid={!o.Id}&sval={!o.Score}&date={!o.DateVal}
		ApexPages.currentPage().getParameters().put('name', ct.Name);
		ApexPages.currentPage().getParameters().put('sc', 'c');
		ApexPages.currentPage().getParameters().put('cid', ct.Id);
		ApexPages.currentPage().getParameters().put('sval', (69+77)+'');
		ApexPages.currentPage().getParameters().put('date', 
		date.today().month()+'/'+date.today().day()+'/'+date.today().year());
		
		XScoreDetailsController controller = new XScoreDetailsController();
		Integer numOfScores = controller.scoreDetails.size();
		System.assertEquals(2, numOfScores);
		System.assertEquals('measureDesc', controller.measureDesc);
		
	}
	
	static TestMethod void TestControllerWithCorrectAccountParam(){
		
		PageReference pageRef = Page.XScoreDetails;
		
		Test.setCurrentPage(pageRef);
		Test.startTest(); 
///////////////////////////////
		
		Account_Earned_Score__c[] score = new Account_Earned_Score__c[]{};
		Measure__c measure = new Measure__c(name='measure', Description__c='measureDescAcc');
		Rule__c rule1 = new Rule__c(name='rule1', description__c = 'desc1');
        Rule__c rule2 = new Rule__c(name='rule2', description__c = 'desc2');
        Account act = new Account(name='testing');
        insert measure;
        insert rule1;
        insert rule2;
        insert act;
        
        Account_Earned_Score__c cs = new Account_Earned_Score__c(account__c = act.Id,
         measure_id__c = measure.Id, rule__c = rule1.Id, score__c = 69);
         
        Account_Earned_Score__c cs2 = new Account_Earned_Score__c(account__c = act.Id,
         measure_id__c = measure.Id, rule__c = rule2.Id, score__c = 77);
		
        insert cs;
        insert cs2;
///////////////////////////////
        Test.stopTest();
        //name={!o.Name}&sc=E&cid={!o.Id}&sval={!o.Score}&date={!o.DateVal}
		ApexPages.currentPage().getParameters().put('name', act.Name);
		ApexPages.currentPage().getParameters().put('sc', 'Ea');
		ApexPages.currentPage().getParameters().put('aid', act.Id);
		ApexPages.currentPage().getParameters().put('sval', (69+77)+'');
		ApexPages.currentPage().getParameters().put('date', 
		date.today().month()+'/'+date.today().day()+'/'+date.today().year());
		
		XScoreDetailsController controller = new XScoreDetailsController();
		Integer numOfScores = controller.scoreDetails.size();
		System.assertEquals(2, numOfScores);
		System.assertEquals('measureDescAcc', controller.measureDesc);
		
	}
}