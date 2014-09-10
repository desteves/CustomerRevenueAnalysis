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
private class XScenarioTest {
    static testMethod void initTest() {
        Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		
		XScenarioController ctlr = new XScenarioController();
		
		System.assertEquals(2+1, ctlr.scenarios.size());
		System.assertEquals(2+1, ctlr.groupLists.size());

    }
    static testMethod void savingScenarioTest() {
    	Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		XScenarioController ctlr = new XScenarioController();
		ctlr.selectedScenario='Create new Scenario..';
		ctlr.go();
		
		ctlr.scenarioName = 'Me me';
		ctlr.create();
		System.assertEquals((2+1)+1, ctlr.scenarios.size());
    }
    
    static testMethod void savingGroupTest() {
        Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		XScenarioController ctlr = new XScenarioController();
		ctlr.selectedScenario='S1';
		ctlr.selectedList='Create new group..';
		ctlr.go();
		string groupName = 'Me me';
		ctlr.groupName = groupName;
		ctlr.contactName = c1.Id;
		ctlr.addContact();
		ctlr.contactName = c2.Id;
		ctlr.addContact();
		
		ctlr.save();
		List<Group_Member__c> members = 
			[SELECT Contact_ID__r.ID 
			FROM Group_Member__c 
			WHERE Group_Id__r.Name = :groupName]; 
		
		System.assertEquals((2+1)+1, ctlr.groupLists.size());
		System.assertEquals(2, members.size());
    }
    
        static testMethod void removeContactInvalidContactTest() {
        Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		XScenarioController ctlr = new XScenarioController();
		ctlr.selectedScenario='S1';
		ctlr.selectedList='Create new group..';
		ctlr.go();
		string groupName = 'Me me';
		ctlr.groupName = groupName;
		ctlr.contactName = c1.Id;
		ctlr.addContact();
		ctlr.contactName = c2.Id;
		ctlr.addContact();
		ctlr.contactName = 'Blah';
		ctlr.addContact();
		
		ctlr.contactName = c2.Id;
		ctlr.remove();
		ctlr.save();
		List<Group_Member__c> members = 
			[SELECT Contact_ID__r.ID 
			FROM Group_Member__c 
			WHERE Group_ID__r.Name = :groupName]; 
		
		System.assertEquals((2+1)+1, ctlr.groupLists.size());
		System.assertEquals(1, members.size());
    }
    static testMethod void redirectToMeasureBuilderWithCorrectParamTest() {
        Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		XScenarioController ctlr = new XScenarioController();
		
		ctlr.selectedScenario = s1.Id;
		ctlr.selectedList = g1.Id;
		ctlr.selectedMeasure ='Create new Measure..';
		
		PageReference pg = ctlr.go();
		System.assertEquals('/apex/x360builder?groupid='+g1.Id+'&scenarioid='+s1.Id, pg.getUrl());
		
    }
    
    static testMethod void redirectToMeasureExecutor() {
        Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		XScenarioController ctlr = new XScenarioController();
		
		ctlr.selectedScenario = s1.Id;
		ctlr.selectedList = g2.Id;
		ctlr.selectedMeasure = m1.Id;
		ctlr.execute();
		
		System.assertEquals('The measure was not fully executed. Please contact your administrator', ctlr.debug);
    }
    
    static testMethod void displayTheTest() {
        Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		XScenarioController ctlr = new XScenarioController();
		
		ctlr.selectedScenario = s1.Id;
		ctlr.selectedList = g1.Id;
		ctlr.selectedMeasure = m1.Id;
		ctlr.scenarios_SelectedIndexChanged();
		ctlr.selectedList = g1.Id;
		ctlr.selectedMeasure = m1.Id;

		ctlr.go();
		
		System.assertEquals((2+2), ctlr.scoreDetails.size());
    }
    
        static testMethod void promoteMeasureTest() {
        Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		XScenarioController ctlr = new XScenarioController();
		
		ctlr.selectedScenario = s1.Id;
		ctlr.selectedList = g1.Id;
		ctlr.selectedMeasure = m1.Id;
		ctlr.scenarios_SelectedIndexChanged();
		ctlr.selectedList = g1.Id;
		ctlr.selectedMeasure = m1.Id;

		ctlr.promote();
		Measure__c m = 
			[SELECT Name, Definition__c
			FROM Measure__c
			WHERE Name = :m1.Name];
		System.assertEquals(m.Name, m1.Name);
		System.assertEquals(m.Definition__c, m1.Definition__c);
		System.assertEquals('The Measure "' + m1.Name +'" is ready for scheduling', ctlr.debug);
    }
    
    static testMethod void savingGroupExceptionTest() {
        Test.startTest(); 
///////////////////////////////
		prepTests();
///////////////////////////////
		Test.stopTest();
		PageReference pageRef = Page.XScenario;
		Test.setCurrentPage(pageRef);
		XScenarioController ctlr = new XScenarioController();
		ctlr.selectedScenario='S1';
		ctlr.selectedList='Create new group..';
		ctlr.go();
		string groupName = null;
		ctlr.groupName = groupName;
		ctlr.members = null;
		
		ctlr.save();
		System.assertEquals('The group cannot be saved', ctlr.debug);
    }
    static Contact c1;
	static Contact c2;
	static Scenario_Measure__c m1;
	static Scenario__c s1;
	static Contacts_Group__c g1;
	static Contacts_Group__c g2;
    private static void prepTests(){
    	s1 = new Scenario__c(name = 'S1');
		Scenario__c s2 = new Scenario__c(name = 'S2');
		insert s1;
		insert s2;
		
		c1 = new Contact(lastName='c1', firstname = 'c1');
		c2 = new Contact(lastName='c2', firstname = 'c2');
		insert c1;
		insert c2;
		
		g1 = new Contacts_Group__c(Name='g1');
		g2 = new Contacts_Group__c(Name='g2');
		insert g1;
		insert g2;
		
		Group_Member__c gm1 = new Group_Member__c(Group_Id__c = g1.Id, Contact_ID__c = c1.id);
		Group_Member__c gm2 = new Group_Member__c(Group_Id__c = g2.Id, Contact_ID__c = c1.id);
		Group_Member__c gm3 = new Group_Member__c(Group_Id__c = g1.Id, Contact_ID__c = c2.id);
		insert gm1;
		insert gm2;
		insert gm3;
		
		m1 = new Scenario_Measure__c(
			Name='m1', 
			Description__c='BBB', 
			Definition__c='BB', 
			MeasureType__c='AER',
			scenario_Id__c = s1.Id, 
			Group_ID__c = g1.id);
		
		Scenario_Measure__c m2 = 
		new Scenario_Measure__c(Name='m2', Description__c='BB', Definition__c='BB', MeasureType__c='AER',
		scenario_Id__c = s1.Id, Group_ID__c = g2.id);
		insert m1;
		insert m2;
		
		Rule__c r1 = new Rule__c(name='rule1', description__c = 'desc1');
        Rule__c r2 = new Rule__c(name='rule2', description__c = 'desc2');
        insert r1;
        insert r2;
		
		Scenario_Score__c sc1 = new Scenario_Score__c(
			Score__c=10, 
			Rule_Id__c = r1.Id,
			Calculation_Date__c = Date.today(), 
			Contact_Id__c = c1.id, 
			Scenario_Measure__c=m1.id);
			
		Scenario_Score__c sc2 = new Scenario_Score__c(
			Score__c=40, 
			Rule_Id__c = r2.Id,
			Calculation_Date__c = Date.today(), 
			Contact_Id__c = c1.id, 
			Scenario_Measure__c=m1.id);
			
		 Scenario_Score__c sc3 = new Scenario_Score__c(
		 	Score__c=20, 
		 	Rule_Id__c = r1.Id,
		 	Calculation_Date__c = Date.today(), 
		 	Contact_Id__c = c2.id, 
		 	Scenario_Measure__c=m1.id);
		 	
		Scenario_Score__c sc4 = new Scenario_Score__c(
			Score__c=30, 
			Rule_Id__c = r2.Id,
			Calculation_Date__c = Date.today(), 
			Contact_Id__c = c2.id, 
			Scenario_Measure__c=m1.id);
			
		Scenario_Score__c sc5 = new Scenario_Score__c(
			Score__c=30, 
			Rule_Id__c = r2.Id,
			Calculation_Date__c = Date.today(), 
			Contact_Id__c = c2.id, 
			Scenario_Measure__c=m2.id);
		
		insert sc1;
        insert sc2;
        insert sc3;
        insert sc4;
        insert sc5;
    }
}