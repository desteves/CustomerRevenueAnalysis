/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class XScoreQuadrantsTest {

    static testMethod void NoScoresNoTierTest() {
        Test.startTest(); 
///////////////////////////////
		insertContacts();
///////////////////////////////
		Test.stopTest();

		ApexPages.StandardController stdCtlr = new ApexPages.StandardController(c1);
		XScoresQuadrantsController ctlr = new XScoresQuadrantsController(stdCtlr);
	System.assertEquals(0, ctlr.historicalEarnedScore.Score);
    System.assertEquals(0, ctlr.historicalContributedScore.Score);
    System.assertEquals(0, ctlr.potentialEarnedScore.Score);
    System.assertEquals(0, ctlr.potentialContributedScore.Score);
    System.assertEquals(null, ctlr.tier);		
		 
    }
    static testMethod void tierNoScoresTest() {
        Test.startTest(); 
///////////////////////////////
		insertContacts();
		insertTier(c1, 'Gold');
///////////////////////////////
		Test.stopTest();

		ApexPages.StandardController stdCtlr = new ApexPages.StandardController(c1);
		XScoresQuadrantsController ctlr = new XScoresQuadrantsController(stdCtlr);
		System.assertEquals(0, ctlr.historicalEarnedScore.Score);
	    System.assertEquals(0, ctlr.historicalContributedScore.Score);
	    System.assertEquals(0, ctlr.potentialEarnedScore.Score);
	    System.assertEquals(0, ctlr.potentialContributedScore.Score);
	    System.assertEquals('Gold', ctlr.tier);		
    }
    static testMethod void scoresTierTest() {
        Test.startTest(); 
///////////////////////////////
		insertContacts();
		insertTier(c1, 'Bronze');
		insertAllScoresForContact(c1);
///////////////////////////////
		Test.stopTest();

		ApexPages.StandardController stdCtlr = new ApexPages.StandardController(c1);
		XScoresQuadrantsController ctlr = new XScoresQuadrantsController(stdCtlr);
		System.assertEquals(90, ctlr.historicalEarnedScore.Score);
	    System.assertEquals(100, ctlr.historicalContributedScore.Score);
	    System.assertEquals(70, ctlr.potentialEarnedScore.Score);
	    System.assertEquals(0, ctlr.potentialContributedScore.Score);
	    System.assertEquals('Bronze', ctlr.tier);	
    }
    
    static testMethod void noScoresSilverTierTest() {
        Test.startTest(); 
///////////////////////////////
		insertContacts();
		insertTier(c1, 'Silver');
///////////////////////////////
		Test.stopTest();

		ApexPages.StandardController stdCtlr = new ApexPages.StandardController(c1);
		XScoresQuadrantsController ctlr = new XScoresQuadrantsController(stdCtlr);
		System.assertEquals(0, ctlr.historicalEarnedScore.Score);
	    System.assertEquals(0, ctlr.historicalContributedScore.Score);
	    System.assertEquals(0, ctlr.potentialEarnedScore.Score);
	    System.assertEquals(0, ctlr.potentialContributedScore.Score);
	    System.assertEquals('Silver', ctlr.tier);	
    }
    static testMethod void noScoresUnkownTierTest() {
        Test.startTest(); 
///////////////////////////////
		insertContacts();
		insertTier(c1, 'Shitty');
///////////////////////////////
		Test.stopTest();

		ApexPages.StandardController stdCtlr = new ApexPages.StandardController(c1);
		XScoresQuadrantsController ctlr = new XScoresQuadrantsController(stdCtlr);
		System.assertEquals(0, ctlr.historicalEarnedScore.Score);
	    System.assertEquals(0, ctlr.historicalContributedScore.Score);
	    System.assertEquals(0, ctlr.potentialEarnedScore.Score);
	    System.assertEquals(0, ctlr.potentialContributedScore.Score);
	    System.assertEquals('Shitty', ctlr.tier);
	    System.assertEquals('white;', ctlr.color);	
    }
    
    static Contact c1;
	static Contact c2;
    private static void insertContacts(){
    	c1 = new Contact(lastName='c1', firstname = 'c1');
		c2 = new Contact(lastName='c2', firstname = 'c2');
		insert c1;
		insert c2;
    }
    private static void insertTier(Contact c, string name){
    	Tier__c t1 = new Tier__c(Name__c= name, Description__c = 'Magisterial');
		insert t1;
		c.Tier_Id__c = t1.Id;
		update c;
    }
    private static void insertAllScoresForContact(Contact c){
		Measure__c measure = new Measure__c(name='measure', Description__c='measureDesc', Active__c = true);
		Rule__c rule1 = new Rule__c(name='rule1', description__c = 'desc1');
        insert measure;
        insert rule1;
        
		Contributed_Score__c s1 = new Contributed_Score__c(Score__c = 100,
		COntact_Id__c = c.Id,
		Calc_DT__c = Datetime.now(),
		Measure_ID__c = measure.Id,
		rule__c= rule1.Id);
		insert s1;
		
		Earned_Score__c s2 = new Earned_Score__c(Score__c = 90,
		COntact_Id__c = c.Id,
		Calc_DT__c = Datetime.now(),
		Measure_ID__c = measure.Id,
		rule__c= rule1.Id);
		insert s2;
		
		/*
		[NEW_OBJ] s3 = new [NEW_OBJ](Score__c = 80,
		COntact_Id__c = c.Id,
		Calc_DT__c = Datetime.now(),
		Measure_ID__c = measure.Id,
		rule__c= rule1.Id);
		insert s3;
		}
		*/
		Expected_Score__c s4 = new Expected_Score__c(Score__c = 70,
		COntact_Id__c = c.Id,
		Calc_DT__c = Datetime.now(),
		Measure_ID__c = measure.Id,
		rule__c= rule1.Id);
		insert s4;
	}
}