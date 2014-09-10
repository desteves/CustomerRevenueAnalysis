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
private class X360ScheduleTest {
    
    /**
     * 
     * Tests X360Schedulable
     * 
    **/
    static testmethod void X360SchedulableTest()
    {
        Test.startTest();
        X360Schedulable sh1 = new X360Schedulable();
        String sch = '0 0 23 * * ?';
        id job = system.schedule('X360SchedulableTestCheck', sch, sh1);              
        System.assertEquals(job, [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'X360SchedulableTestCheck'].Id);
        System.assertEquals(sch, [SELECT CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'X360SchedulableTestCheck'].CronExpression);
        Test.stopTest(); 
    }
    
    /**
     * Without having a scheduler already in the system
     * 
    **/
    static testmethod void X360ScheduleTestDefaults()
    {
        PageReference pageRef = Page.X360SchedulePage;
        Test.setCurrentPage(pageRef);    
        Test.startTest();
        X360ScheduleController controller = new X360ScheduleController();    
        System.assertEquals(false, controller.scheduled);
        Test.stopTest(); 
    }
    
    /**
     * Tests having a scheudle already in the system 
     * 
    **/
    static testmethod void X360ScheduleTestExisting()
    {
        PageReference pageRef = Page.X360SchedulePage;
        Test.setCurrentPage(pageRef);    
        Test.startTest();
        id job = system.schedule(X360ExecutorConstants.DEFAULT_JOB_NAME, 
                        '0 0 0 3 * ? 2014-2099',
                        new X360Schedulable());
        X360ScheduleController controller = new X360ScheduleController();    
        System.assertEquals(job, controller.jobID);        
        System.assertEquals(true, controller.scheduled);
        controller.deleteSchedulable();
        System.assertEquals(false, controller.scheduled);
        Test.stopTest(); 
    }
        
    /**
     * Tests redirection of edit schedule 
     * 
    **/
    static testmethod void X360ScheduleTestEdit()
    {
        PageReference pageRef = Page.X360SchedulePage;
        Test.setCurrentPage(pageRef);        
        Test.startTest();    
        system.schedule(X360ExecutorConstants.DEFAULT_JOB_NAME, 
                        '0 0 0 3 * ? 2014-2099',
                        new X360Schedulable());
        X360ScheduleController controller = new X360ScheduleController();    
        String nextPage = controller.newSchedulable().getUrl();  
        
        System.assertEquals(controller.newSchedule, nextPage);
      //  System.assert(controller.newSchedule.equalsIgnoreCase(nextPage));
        Test.stopTest(); 
    }
    /**
     * Tests redirection of new schedule 
     * 
    **/
    static testmethod void X360ScheduleTestNew()
    {
        PageReference pageRef = Page.X360SchedulePage;
        Test.setCurrentPage(pageRef);    
        X360ScheduleController controller = new X360ScheduleController();  
        String nextPage = controller.newSchedulable().getUrl();  
        System.assertEquals(controller.newSchedule, nextPage);
    }
    /**
     * Tests default measures
     * 
    **/
    static testmethod void X360ScheduleTestMeasuresDefaults()
    {
        PageReference pageRef = Page.X360SchedulePage;
        Test.setCurrentPage(pageRef);    
        Test.startTest();   
        // no data     
        X360ScheduleController controller = new X360ScheduleController();        
        controller.saveMeasures();  
        System.assertEquals('Job updated with selected measures.', controller.message); 
        Test.stopTest(); 
    }
    
    /**
     * Tests editing measures
     * 
    **/
    static testmethod void X360ScheduleTestMeasuresEditI()
    {
        PageReference pageRef = Page.X360SchedulePage;
        Test.setCurrentPage(pageRef);    
        Test.startTest();   
        //insert dummy measures          
        // Account Earned Revenue  -- AER ---> AHE   
    	Measure_Type__c mtype_aer = new Measure_Type__c(Name = 'Account - Historical Earned Value');
    	mtype_aer.Measure_Type_Code__c = 'AHE';   
    	insert mtype_aer;   
        Measure__c aer =  new Measure__c(Name = 'Unit Test AHE');       
        aer.MeasureType__c = mtype_aer.Id;      
        aer.Executable__c = true ;
        aer.Definition__c = '<Rules />';
        insert aer;        
        
        
        // Account Expected -- AEX ---> APC
    	Measure_Type__c mtype_aex = new Measure_Type__c(Name = 'Account - Potential Earning');
    	mtype_aex.Measure_Type_Code__c = 'APC';
    	insert mtype_aex;
        Measure__c aex =  new Measure__c(Name = 'Unit Test APC');      
        aex.MeasureType__c = mtype_aex.Id;       
        aex.Executable__c = true ;
        aex.Definition__c = '<Rules />';
        insert aex;
        
        
        // Contact Value Contributed -- CVC -> CHC
    	Measure_Type__c mtype_cvc = new Measure_Type__c(Name = 'Contact - Historical Contributed Value');
    	mtype_cvc.Measure_Type_Code__c = 'CHC';
    	insert mtype_cvc;
        Measure__c cvc =  new Measure__c(Name = 'Unit Test CHC');      
        cvc.MeasureType__c = mtype_cvc.Id;      
        cvc.Executable__c = false ;
        cvc.Definition__c = '<Rules />';
        insert cvc;        
        
              
        X360ScheduleController controller = new X360ScheduleController();                 
        controller.selectedMeasures.add(new SelectOption(cvc.Id, cvc.Name));         
        controller.saveMeasures();  
        System.assertEquals('Job updated with selected measures.', controller.message); 
        Test.stopTest(); 
    }
   
    
    
    /**
     * Tests editing measures
     * 
    **/
    static testmethod void X360ScheduleTestMeasuresEditII()
    {
        PageReference pageRef = Page.X360SchedulePage;
        Test.setCurrentPage(pageRef);    
        Test.startTest();   
        //insert dummy measures  
		// Account Earned Revenue  -- AER ---> AHE   
    	Measure_Type__c mtype_aer = new Measure_Type__c(Name = 'Account - Historical Earned Value');
    	mtype_aer.Measure_Type_Code__c = 'AHE';   
    	insert mtype_aer;   
        Measure__c aer =  new Measure__c(Name = 'Unit Test AHE');       
        aer.MeasureType__c = mtype_aer.Id;      
        aer.Executable__c = true ;
        aer.Definition__c = '<Rules />';
        insert aer;        
        
        
        // Account Expected -- AEX ---> APC
    	Measure_Type__c mtype_aex = new Measure_Type__c(Name = 'Account - Potential Earning');
    	mtype_aex.Measure_Type_Code__c = 'APC';
    	insert mtype_aex;
        Measure__c aex =  new Measure__c(Name = 'Unit Test APC');      
        aex.MeasureType__c = mtype_aex.Id;       
        aex.Executable__c = true ;
        aex.Definition__c = '<Rules />';
        insert aex;
        
        
        // Contact Value Contributed -- CVC -> CHC
    	Measure_Type__c mtype_cvc = new Measure_Type__c(Name = 'Contact - Historical Contributed Value');
    	mtype_cvc.Measure_Type_Code__c = 'CHC';
    	insert mtype_cvc;
        Measure__c cvc =  new Measure__c(Name = 'Unit Test CHC');      
        cvc.MeasureType__c = mtype_cvc.Id;      
        cvc.Executable__c = true ;
        cvc.Definition__c = '<Rules />';
        insert cvc; 
        X360ScheduleController controller = new X360ScheduleController();         
        controller.selectedMeasures.clear();         
        controller.saveMeasures();  
        System.assertEquals('Job updated with selected measures.', controller.message); 
        Test.stopTest(); 
    }

}