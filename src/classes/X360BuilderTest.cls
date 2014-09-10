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
 *
 * X360Buildertest is test class for X360BuilderController. 
 */
@isTest
private class X360BuilderTest {


	// Add a rule and check if it is ahown in rules list. 
	// Save a measure and check XML generation
    static testMethod void testMeasureSaveAndRuleList() {
        // TO DO: implement unit test
        Test.startTest();
        
        Rule__c rule1 = new rule__c();
        rule1.Definition__c='<Rule name="High Participation" entity="Contact"><Desc>check the number of programs a contact is related to.</Desc><Params><Param id="P01" fun="Count" Datatype="PICKLIST" multiple="false" operator="&gt;"><Values><value>1</value></Values></Param></Params><Query>SELECT Contact__r.ID FROM Program_Participation__c GROUP BY Contact__r.ID HAVING   Count(ID) &gt; P01</Query></Rule>';
        rule1.Description__c = 'sample rule';
        rule1.Type__c = 'Account';
        rule1.Name = 'sample rule Name';
        insert rule1;
        
        
        
        X360BuilderController cntrl = new X360BuilderController();
        
        System.assertEquals(cntrl.rulesUI.size(),1);
        
        
       // X360BuilderController.MeasureDefinition mea = new X360BuilderController.MeasureDefinition();
        
        
        
        
        cntrl.measureDef= '{"MeasureName":"Test","MeasureDescr":"------------------","MeasureType":"Contact","RulesDefs":[{"id":"a14f0000001EXUqAAO","params":[{"id":"P01","value":"Advertisement - Print"}]},{"id":"a14f0000001EGyDAAW","params":[{"id":"P01","value":"Advertisement - Web,Cold Call/Visit,Direct Mail Appeal"}]},{"id":"a14f0000001EGxjAAG","params":[{"id":"P01","value":"07/08/2014"}]}]}';
        cntrl.getSave();
        
        List<Measure__c> measures = [SELECT ID from Measure__c];
        
        System.assertEquals(measures.size(),1);
        
        Test.stopTest();
       
    }
    
    
    //negative for meausre
    static testMethod void testNegativeMeasureSave() {
        // TO DO: implement unit test
        Test.startTest();
       
        X360BuilderController cntrl = new X360BuilderController();
        
        System.assertEquals(cntrl.rulesUI.size(),1);
        
        
       // X360BuilderController.MeasureDefinition mea = new X360BuilderController.MeasureDefinition();
        
        
        
        
        cntrl.measureDef= '{"MeasureName":"Test","MeasureDescr":"------------------","MeasureT:"a14f0000001EXUqAAO","params":["id":"P01","value":"Advertisement - Print"}]},{"id":"a14f0000001EGyDAAW","params":[{"id":"P01","value":"Advertisement - Web,Cold Call/Visit,Direct Mail Appeal"}]},{"id":"a14f0000001EGxjAAG","params":[{"id":"P01","value":"07/08/2014"}]}]}';
        cntrl.getSave();
        
       
        
        System.assertEquals(cntrl.measureDef,'Error occurred. Contact administrator');
        
        Test.stopTest();
       
    }
    
}