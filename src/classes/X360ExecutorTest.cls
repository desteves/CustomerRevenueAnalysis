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
private class X360ExecutorTest {

	/********************************
	/********************************
	
			Measures & Rules
	 
	 ********************************
	 ********************************/
	 
	 // TODO Test the following: 
	 // Test scenario measure execution
	 // Measure with each possible type
	 // Measure with illegal type
	 // Bad formed measure/rule
	 // Rule with no hits
	 // Schedule measure execution
	 // Email notification
	 // 
	 // https://www.salesforce.com/us/developer/docs/pages/Content/pages_controller_error_handling.htm
	
	static testMethod void TestExecutorAsJobWithoutScores()
	{
		PageReference pageRef = Page.X360SchedulePage;
        Test.setCurrentPage(pageRef);    
        Test.startTest();
        X360Executor controller = new X360Executor();            
        String message = controller.execute();
         // Verify that page fails without any measures to execute
        ///////System.assertThat(message, );//'/apex/x360schedulepage?error=noMeasures', nextPage);     	     
        Test.stopTest();   
	}
	
	/**
     * 
     * Test the measure with a score for each type -- Contact
     * 
    **/
    static testMethod void TestExecutorAsJobWithScoresContact()
    {
        PageReference pageRef = Page.X360MeasurePage;
        Test.setCurrentPage(pageRef);    
        X360Executor x360Executor = new X360Executor();     
        //start test ----------------------------------------------------------
        Test.startTest(); 
        
        //insert dummy measure ------------------------------------------------
    	Measure_Type__c mtype_cvc = new Measure_Type__c(Name = 'Contact - Historical Contributed Value');
    	mtype_cvc.Measure_Type_Code__c = 'CHC';
    	insert mtype_cvc;
    	Measure_Type__c insertedMeasureType = [SELECT name FROM Measure_Type__c WHERE Id = :mtype_cvc.Id];
        System.assertEquals('Contact - Historical Contributed Value', insertedMeasureType.name);         
    	
    	//insert dummy rule ---------------------------------------------------
        Rule__c r_ct = new Rule__c(name='Unit Test Contact', 
        						   description__c = 'desc1', 
    							   Measure_type__c = mtype_cvc.Id,
        						   definition__c  = '<?xml version="1.0"?><Rule><Params><Param id="P01" type="String"/></Params><Query>Select Id From Contact Where firstname = \'P01\'</Query></Rule>');
        insert r_ct;
    	Rule__c insertedRule = [SELECT name FROM Rule__c WHERE Id = :r_ct.Id];
        System.assertEquals('Unit Test Contact', insertedRule.name);           //a14f0000001EfDUAA0
        Id id_ct = r_ct.Id; //the rule's id
       
		//insert dummy contact  -----------------------------------------------        
        Contact ct = new Contact(lastname='unittesting',firstname='apex');    
        insert ct;     
    	Contact insertedContact = [SELECT name FROM Contact WHERE Id = :ct.Id];
        System.assertEquals('apex unittesting', insertedContact.name);  //003f000000hfzchAAA
        Id id_co = ct.Id;  // contact's id   
                     
        //insert dummy measures -- one of each type to be calculated ----------
        // Contact Value Contributed -- CVC -> CHC 
        Measure__c measure =  new Measure__c(Name = 'Unit Test CHC');      
        measure.MeasureType__c = mtype_cvc.Id;             
        measure.Active__c     = true;       
        measure.Executable__c = true ;
        measure.Definition__c = '<Rules><Rule ID="'+ id_ct +'" Score="20"><Params><Param id="P01">apex</Param></Params></Rule></Rules>';
        insert measure;           
    	Measure__c insertedMeasure = [SELECT name FROM Measure__c WHERE Id = :measure.Id];
        System.assertEquals('Unit Test CHC', insertedMeasure.name);  //a12f0000000Zrw2AAC
        // --------------------------------------------------------------------
        Test.stopTest();
        
        String message =  x360Executor.execute();   
        Contributed_Score__c cvc = [SELECT id, Score__c, Contact_Id__r.Id , Rule__r.Id  FROM Contributed_Score__c WHERE Name = 'CHC Autocalculated' limit 1];
        System.assertEquals(id_co, cvc.Contact_Id__r.Id);   
        System.assertEquals(id_ct, cvc.Rule__r.Id);   
        System.assertEquals(20 , cvc.Score__c);
         // Verify that the success page displays   
        System.assert(!message.contains('! Error - '));
    }
    
    /**
     * 
     * Test the measure without definition
     * 
    **/
    static testMethod void TestExecutorAsJobWithoutDefinition()
    {
        PageReference pageRef = Page.X360MeasurePage;
        Test.setCurrentPage(pageRef);    
        X360Executor x360Executor = new X360Executor();     
        //start test ----------------------------------------------------------
        Test.startTest();         
        //insert dummy measure ------------------------------------------------
    	Measure_Type__c mtype_cvc = new Measure_Type__c(Name = 'Contact - Historical Contributed Value');
    	mtype_cvc.Measure_Type_Code__c = 'CHC';
    	insert mtype_cvc;
    	//insert dummy rule ---------------------------------------------------
        Rule__c r_ct = new Rule__c(name='Unit Test Contact', 
        						   description__c = 'desc1', 
    							   Measure_type__c = mtype_cvc.Id,
        						   definition__c  = '');
        insert r_ct;
    	Rule__c insertedRule = [SELECT name FROM Rule__c WHERE Id = :r_ct.Id];                     
        //insert dummy measures -- one of each type to be calculated ----------
        // Contact Value Contributed -- CVC -> CHC 
        Measure__c measure =  new Measure__c(Name = 'Unit Test CHC');      
        measure.MeasureType__c = mtype_cvc.Id;             
        measure.Active__c     = true;       
        measure.Executable__c = true ;
        measure.Definition__c = ''; //xmlRules.length() == 0
        insert measure;           
    	Measure__c insertedMeasure = [SELECT name FROM Measure__c WHERE Id = :measure.Id];
        System.assertEquals('Unit Test CHC', insertedMeasure.name);  //a12f0000000Zrw2AAC
        // --------------------------------------------------------------------
        Test.stopTest();        
        String message =  x360Executor.execute();   
         // Verify that the success page displays   
        System.assert(!message.contains('insert'));
    }
    
    /**
     * 
     * Test the measure with a score for each type -- Account
     * 
    **/
    static testMethod void TestExecutorAsJobWithScoresAccount()
    {
        PageReference pageRef = Page.X360MeasurePage;
        Test.setCurrentPage(pageRef);    
        X360Executor x360Executor = new X360Executor();     
        //start test ----------------------------------------------------------
        Test.startTest(); 
        
        //insert dummy measure ------------------------------------------------
    	Measure_Type__c mtype = new Measure_Type__c(Name = 'Account - Historical Earned Value');
    	mtype.Measure_Type_Code__c = 'AHE';
    	insert mtype;
    	Measure_Type__c insertedMeasureType = [SELECT name FROM Measure_Type__c WHERE Id = :mtype.Id];
        System.assertEquals(mtype.Name, insertedMeasureType.name);         
    	
    	//insert dummy rule ---------------------------------------------------
        Rule__c rule = new Rule__c(name='Unit Test Account', 
        						   description__c = 'desc1', 
    							   Measure_type__c = mtype.Id,
        						   definition__c  = '<?xml version="1.0"?><Rule><Params><Param id="P01" type="String"/></Params><Query>Select Id From Account Where name = \'P01\'</Query></Rule>');
        insert rule;
    	Rule__c insertedRule = [SELECT name FROM Rule__c WHERE Id = :rule.Id];
        System.assertEquals(rule.Name, insertedRule.name);
        Id rule_id = rule.Id; //the rule's id
       
		//insert dummy account  -----------------------------------------------        
        Account entity = new Account(name='CMU');    
        insert entity;     
    	Account insertedEntity = [SELECT name FROM Account WHERE Id = :entity.Id];
        System.assertEquals(entity.Name, insertedEntity.name); 
        Id entity_id = entity.Id;  // contact's id   
                     
        //insert dummy measures -- one of each type to be calculated ----------
        // Account Earned Revenue  -- AER ---> AHE       	       
        Measure__c measure =  new Measure__c(Name = 'Unit Test AHE');      
        measure.MeasureType__c = mtype.Id;             
        measure.Active__c     = true;       
        measure.Executable__c = true ;
        measure.Definition__c = '<Rules><Rule ID="'+ rule_id +'" Score="20"><Params><Param id="P01">CMU</Param></Params></Rule></Rules>';
        insert measure;           
    	Measure__c insertedMeasure = [SELECT name FROM Measure__c WHERE Id = :measure.Id];
        System.assertEquals(measure.Name, insertedMeasure.name);
        // --------------------------------------------------------------------
        Test.stopTest();
        
        String message =  x360Executor.execute();   
        Account_Earned_Score__c table = [SELECT id, Score__c, Account__r.Id , Rule__r.Id  FROM Account_Earned_Score__c WHERE Name = 'AHE Autocalculated' limit 1];
        System.assertEquals(entity_id, table.Account__r.Id);  
        System.assertEquals(rule_id, table.Rule__r.Id   );  
        System.assertEquals(20  , table.Score__c      ); 
         // Verify that the success page displays   
        System.assert(!message.contains('! Error - '));
    }
	
	   /**
     * 
     * Test the measure without any executables
     * 
    **/
    static testMethod void TestExecutorAsJobWithoutExecutables()
    {
        PageReference pageRef = Page.X360MeasurePage;
        Test.setCurrentPage(pageRef);    
        X360Executor x360Executor = new X360Executor();     
        //start test ----------------------------------------------------------
        Test.startTest(); 
        
        //insert dummy measure ------------------------------------------------
    	Measure_Type__c mtype = new Measure_Type__c(Name = 'Account - Historical Earned Value');
    	mtype.Measure_Type_Code__c = 'AHE';
    	insert mtype;
    	Measure_Type__c insertedMeasureType = [SELECT name FROM Measure_Type__c WHERE Id = :mtype.Id];
        System.assertEquals(mtype.Name, insertedMeasureType.name);         
    	          
        //insert dummy measures -- one of each type to be calculated ----------
        // Account Earned Revenue  -- AER ---> AHE       	       
        Measure__c measure =  new Measure__c(Name = 'Unit Test AHE');      
        measure.MeasureType__c = mtype.Id;             
        measure.Active__c     = false;       
        measure.Executable__c = false;
        measure.Definition__c = '<Rules><Rule Score="20"><Params><Param id="P01">CMU</Param></Params></Rule></Rules>';
        insert measure;           
    	Measure__c insertedMeasure = [SELECT name FROM Measure__c WHERE Id = :measure.Id];
        System.assertEquals(measure.Name, insertedMeasure.name);
        String message =  x360Executor.execute();
        // --------------------------------------------------------------------
        Test.stopTest();
        System.assertEquals('', message);
    }
	  /**
     * 
     * Test the measure with bad XML format
     * 
    **/
    static testMethod void TestExecutorAsJobWithBadXML()
    {
        PageReference pageRef = Page.X360MeasurePage;
        Test.setCurrentPage(pageRef);    
        X360Executor x360Executor = new X360Executor();     
        //start test ----------------------------------------------------------
        Test.startTest(); 
        
        //insert dummy measure ------------------------------------------------
    	Measure_Type__c mtype = new Measure_Type__c(Name = 'Account - Historical Earned Value');
    	mtype.Measure_Type_Code__c = 'AHE';
    	insert mtype;
    	Measure_Type__c insertedMeasureType = [SELECT name FROM Measure_Type__c WHERE Id = :mtype.Id];
        System.assertEquals(mtype.Name, insertedMeasureType.name);         
    	
    	//insert dummy rule ---------------------------------------------------
        Rule__c rule = new Rule__c(name='Unit Test Account', 
        						   description__c = 'desc1', 
    							   Measure_type__c = mtype.Id,
        						   definition__c  = '<?xml version="1.0"?><Rule><Params><Param id="P01" type="String"/></Params><Query>Select Id From Account Where name = \'P01\'</Query></Rule>');
        insert rule;
    	Rule__c insertedRule = [SELECT name FROM Rule__c WHERE Id = :rule.Id];
        System.assertEquals(rule.Name, insertedRule.name);
        Id rule_id = rule.Id; //the rule's id
       
		//insert dummy account  -----------------------------------------------        
        Account entity = new Account(name='CMU');    
        insert entity;     
    	Account insertedEntity = [SELECT name FROM Account WHERE Id = :entity.Id];
        System.assertEquals(entity.Name, insertedEntity.name); 
        Id entity_id = entity.Id;  // contact's id   
                     
        //insert dummy measures -- one of each type to be calculated ----------
        // Account Earned Revenue  -- AER ---> AHE       	       
        Measure__c measure =  new Measure__c(Name = 'Unit Test AHE');      
        measure.MeasureType__c = mtype.Id;             
        measure.Active__c     = true;       
        measure.Executable__c = true ;
        measure.Definition__c = '<Rules><Rule Score="20"><Params><Param id="P01">CMU</Param></Params></Rule></Rules>';
        insert measure;           
    	Measure__c insertedMeasure = [SELECT name FROM Measure__c WHERE Id = :measure.Id];
        System.assertEquals(measure.Name, insertedMeasure.name);
        // --------------------------------------------------------------------
        Test.stopTest();
        
        String message =  x360Executor.execute();   
         // Verify that the success page displays   
        System.assert(message.contains('! Error - '));
    }
    

     /**
     * 
     * Tests running a measure on a subset of contacts
     * 
    **/
    static testMethod void TestExecutorAsJobWithSubsetContacts()
    {    	
    	
    	PageReference pageRef = Page.X360MeasurePage;
        Test.setCurrentPage(pageRef);    
    	/////////////////////////////////////////add dummy data  
    	Test.startTest();  	
    	//dummy scenario__c
    	Scenario__c scenario = new Scenario__c(name='unittesting');
    	insert scenario;
    	
    	//dummy contact
      	Contact contact = new Contact(lastname='unittesting',firstname='unittesting');      
        insert contact;     
        
        //dummy group
      	Contacts_Group__c gp = new Contacts_Group__c(Name='unittesting');      
        insert gp; 
        
    	//dummy contact_group__c
    	Group_Member__c filter = new Group_Member__c(Group_Id__c = gp.Id, Contact_Id__c = contact.Id);
    	insert filter;
    	
    	//dummy rules
    	Measure_Type__c mtype_cvc = new Measure_Type__c(Name = 'Contact - Historical Contributed Value');
    	mtype_cvc.Measure_Type_Code__c = 'CHC';
    	insert mtype_cvc;
    	
    	Rule__c rule1 = new Rule__c(name='unittesting', 
    							    description__c = 'unittesting', 
    							    Measure_type__c = mtype_cvc.Id,
    								definition__c  = '<?xml version="1.0"?><Rule name="unittesting" entity="Contact" type="Contact - Historical Contributed Value"><Desc>unittesting</Desc><Params><Param id="P01" Datatype="STRING" multiple="false" operator="="></Param></Params><Query>SELECT ID FROM Contact WHERE   FirstName = \'P01\'</Query></Rule>'
    								);
        Rule__c rule2 = new Rule__c(name='unittesting',
        							description__c = 'unittesting', 
        							Measure_type__c = mtype_cvc.Id,
        							definition__c  = '<?xml version="1.0"?><Rule name="unittesting" entity="Contact" type="Contact - Historical Contributed Value"><Desc>unittesting</Desc><Params><Param id="P01" fun="Count" Datatype="STRING" multiple="false" operator="="></Param></Params><Query>SELECT ID FROM Contact GROUP BY ID HAVING   Count(ID) = P01 LIMIT 1</Query></Rule>'
        							);
        insert rule1;
        insert rule2;
    	
    	//SELECT Id FROM Contact WHERE Id in (SELECT Contact_ID__c FROM Contact_Group__c WHERE Name = 'unittesting') GROUP BY Id HAVING COUNT(Name) = 1 LIMIT 1
    	//SELECT Id FROM Contact WHERE Firstname = 'unittesting'  AND Id in (SELECT Contact_ID__c FROM Contact_Group__c WHERE Name = 'unittesting')
    	
    	//dummy scenario_measure__c
    	
    	Scenario_Measure__c measure = new Scenario_Measure__c(name='unittesting');
    	measure.Group_ID__c = gp.Id;
    	measure.Description__c = 'apex';
    	measure.Definition__c = '<Rules>'+
    							'<Rule ID="'+ rule1.Id +'" Score="20"><Params><Param id="P01">unittesting</Param></Params></Rule>' +
    							'<Rule ID="'+ rule2.Id +'" Score="20"><Params><Param id="P01">1</Param></Params></Rule>' +
    							'</Rules>';
    	measure.Scenario_ID__c = scenario.Id;
    	measure.MeasureType__c = mtype_cvc.Id; 
    	insert measure;
    	
    	    	
    	//start the controller with arguments -- scenario mode
        X360Executor x360Executor = new X360Executor(measure.Id, gp.id);
        x360Executor.executeNow();
    	// check dummy data's score was inserted into scenario_score__c
    	//System.assertEquals(2, x360Executor.ruleList.size());
    	
    	
    	List<Scenario_Score__c> ss = [SELECT Id, Score__c, Scenario_Measure__r.Id, Contact_Id__r.Id , Rule_ID__r.Id  
    								  FROM Scenario_Score__c 
    								  WHERE Name LIKE '%Autocalculated'];
    	System.assertEquals(2, ss.size());		//one per rule
    	 					  
    	for (Scenario_Score__c s:ss)
    	{
	        System.assertEquals(contact.Id, s.Contact_Id__r.Id);   
	        System.assertEquals(measure.Id, s.Scenario_Measure__r.Id);   
	        System.assertEquals(20, s.Score__c);
    	}
    	
    	Test.stopTest();
    }
    
    
    
    
	/********************************
	/********************************
	
					Tiers
	 
	 ********************************
	 ********************************/
}