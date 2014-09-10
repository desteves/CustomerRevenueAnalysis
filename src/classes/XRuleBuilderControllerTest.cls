@isTest
public class XRuleBuilderControllerTest {
	/*
	Test if the controls are populated correctly for a contact
	*/
	static TestMethod void testControllerWithCorrectEntitySelection(){
		Test.setCurrentPage(Page.XRuleBuilder);
		XRuleBuilderController controller = new XRuleBuilderController();
		
		controller.selectedEntity = 'Contact';
        
		controller.entities_SelectedIndexChanged();
		Schema.SObjectType objType = SchemaManager.getObjectSchema(controller.selectedEntity);
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		integer size = objDescribe.getChildRelationships().size();
		String fieldGroup = objDescribe.getChildRelationships()[size-1].getChildSObject()+'';
		
		controller.selectedFieldGroup = fieldGroup;
		controller.fieldsGroup_SelectedIndexChanged();
		Schema.SObjectType fieldGroupObjType = SchemaManager.getObjectSchema(fieldGroup);
		
		integer numOfAtt = getNumberOfAttributes(fieldGroupObjType.getDescribe());
		
		System.assertEquals(controller.fieldsGroup.size(), size+1); // +1 for -- Select --
		System.assertEquals(controller.scoreTypes.size(), 4+1);
		System.assertEquals(controller.FieldsList.size(), numOfAtt);
	}
	
	/*
	counts the number of field retuens 
	*/
	private static integer getNumberOfAttributes(Schema.DescribeSObjectResult objDescribe){
		integer numOfAtt = 1;// 1 for -- Select --
		Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
		for(Schema.SObjectField field: fieldMap.Values()){
	    	Schema.DescribeFieldResult fieldDesc = field.getDescribe();
	    	string type = fieldDesc.getType()+'';
	    	if(!type.equals('REFERENCE') && !type.equals('ID')
	     	&& !type.equals('URL') && !type.equals('BASE64') && !type.equals('ANYTYPE')){
	    		numOfAtt++;
			}
		}
		return numOfAtt;
	}
	
	/*
	Test if the controls are populated correctly for an account
	*/
	static TestMethod void testControllerWithCorrectEntitySelectionAccount(){
		Test.setCurrentPage(Page.XRuleBuilder);
		XRuleBuilderController controller = new XRuleBuilderController();
		
		controller.selectedEntity = 'Account';
        
		controller.entities_SelectedIndexChanged();
		Schema.SObjectType objType = SchemaManager.getObjectSchema(controller.selectedEntity);
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		integer size = objDescribe.getChildRelationships().size();
		String fieldGroup = objDescribe.getChildRelationships()[size-1].getChildSObject()+'';
		
		controller.selectedFieldGroup = fieldGroup;
		controller.fieldsGroup_SelectedIndexChanged();
		Schema.SObjectType fieldGroupObjType = SchemaManager.getObjectSchema(fieldGroup);
		
		integer numOfAtt = getNumberOfAttributes(fieldGroupObjType.getDescribe());
		
		System.assertEquals(controller.fieldsGroup.size(), size+1); // +1 for -- Select --
		System.assertEquals(controller.scoreTypes.size(), 2+1);// +1 for -- Select --
		System.assertEquals(controller.FieldsList.size(), numOfAtt);
	}
	/*
	Test if the controls are populated correctly if the selection was wrong
	*/
	static TestMethod void testControllerWithWrongEntitySelection(){
		Test.setCurrentPage(Page.XRuleBuilder);
		XRuleBuilderController controller = new XRuleBuilderController();
		Test.startTest();
///////////////////////////////
		controller.selectedEntity = 'Blah Blah';
///////////////////////////////
        Test.stopTest();
		controller.entities_SelectedIndexChanged();
        
		controller.entities_SelectedIndexChanged();
		Schema.SObjectType objType = SchemaManager.getObjectSchema(controller.selectedEntity);
		
		System.assertEquals(controller.fieldsGroup.size(), 1);// +1 for -- Select --
		System.assertEquals(controller.scoreTypes.size(), 1);// +1 for -- Select --
		System.assertEquals(controller.FieldsList.size(), 1);// +1 for -- Select --
	}
	
	/*
	Test if the operations diplayed are the right ones based on the field type
	*/
	static TestMethod void testControllerDisplayingRightOperationSet(){
	Test.setCurrentPage(Page.XRuleBuilder);
	XRuleBuilderController controller = new XRuleBuilderController();
	
	controller.selectedEntity = 'Account';
	controller.entities_SelectedIndexChanged();
	controller.selectedScore = 'Earned Historical';
	
	controller.selectedFieldGroup = 'Account_Earned_Score__c';
	controller.fieldsGroup_SelectedIndexChanged();
	
	controller.selectedField = 'Score';
	controller.fieldsList_SelectedIndexChanged();
	
	System.assertEquals(4+1, controller.operations.size());// +1 for -- Select --
	System.assertEquals(5+1, controller.aggregations.size());// +1 for -- Select --
	System.assertEquals(controller.isBool, false);
	System.assertEquals(controller.isDate, false);
	System.assertEquals(controller.isPicklist, false);
		
	}
	
	/*
	Test the save functionalities if there was no param populated
	*/
	static TestMethod void testSaveWithEmptyParams(){
	Test.setCurrentPage(Page.XRuleBuilder);
	XRuleBuilderController controller = new XRuleBuilderController();
	
	controller.save();
	
	System.assertEquals(controller.status, 'There is nothing to save');
		
	}
	
	/*
	Test the save functionality when the user select the operator and an attribute 
	value to be configurable
	*/
	static TestMethod void testSaveWithConfigurableValueAndOperator(){
	Test.setCurrentPage(Page.XRuleBuilder);
	XRuleBuilderController controller = new XRuleBuilderController();
	controller.ruleName = 'test';
	controller.ruleDesc = 'Test';
	controller.selectedEntity = 'Account';
	controller.entities_SelectedIndexChanged();
	controller.selectedScore = 'Earned Historical';
	
	controller.selectedFieldGroup = 'Account_Earned_Score__c';
	controller.fieldsGroup_SelectedIndexChanged();
	
	controller.selectedField = 'Score';
	controller.fieldsList_SelectedIndexChanged();
	
	controller.isParam1 = true;
	
	controller.save();
	
	System.assertEquals(controller.status, 'Saved Successfully.');
		
	}
	
	/*
	Test if the XML generated has the selected picklist values parsed and incorporated
	as part of the rule
	*/
	static TestMethod void testSaveWithPicklistValueAndOperator(){
	Test.setCurrentPage(Page.XRuleBuilder);
	XRuleBuilderController controller = new XRuleBuilderController();
	controller.ruleName = 'test';
	controller.ruleDesc = 'Test';
	controller.selectedEntity = 'Account';
	controller.entities_SelectedIndexChanged();
	controller.selectedScore = 'Earned Historical';
	
	controller.selectedFieldGroup = 'Account_Participation__c';
	controller.fieldsGroup_SelectedIndexChanged();
	
	controller.selectedField = 'Role';
	controller.fieldsList_SelectedIndexChanged();
	
	controller.selectedOp = 'in';
	
	controller.isParam1 = false;
	controller.selectedPicklistItem = '[-- Select --, Teacher]';
	
	
	controller.save();
	
	System.assertEquals(controller.status, 'Saved Successfully.');
		
	}
	
	/*
	Test the save functionality if the user selects Aggregation as part of the rule
	*/
	static TestMethod void testSaveRuleWithAggregation(){
	Test.setCurrentPage(Page.XRuleBuilder);
	XRuleBuilderController controller = new XRuleBuilderController();
	
	controller.ruleName = 'test';
	controller.ruleDesc = 'Test';
	
	controller.selectedEntity = 'Account';
	controller.entities_SelectedIndexChanged();
	controller.selectedScore = 'Earned Historical';
	
	controller.selectedFieldGroup = 'Account_Participation__c';
	controller.fieldsGroup_SelectedIndexChanged();
	
	controller.selectedField = 'Deleted';
	controller.fieldsList_SelectedIndexChanged();
	
	controller.selectedFn = 'Count';
	controller.aggregiations_SelectedIndexChanged();
	
	controller.isParam1 = true;
	
	controller.save();
	
	System.assertEquals(controller.status, 'Saved Successfully.');
		
	}
	
	/*
	Test if the controls are populated correctly based on the selection
	*/
	static TestMethod void testSaveWithConfigurablePicklistValueAndOperator(){
	Test.setCurrentPage(Page.XRuleBuilder);
	XRuleBuilderController controller = new XRuleBuilderController();
	controller.ruleName = 'test';
	controller.ruleDesc = 'Test';
	controller.selectedEntity = 'Contact';
	controller.entities_SelectedIndexChanged();
	controller.selectedScore = 'Earned Historical';
	
	controller.selectedFieldGroup = 'Contact';
	controller.fieldsGroup_SelectedIndexChanged();
	
	controller.selectedField = 'Lead Source';
	controller.fieldsList_SelectedIndexChanged();
	
	controller.selectedOp = 'in';
	
	controller.isParam1 = true;
	
	controller.save();
	
	System.assertEquals(controller.status, 'Saved Successfully.');
		
	}
	
	/*
	Test if the user selects to remove a condition from the list
	*/
	static TestMethod void testRemoveCondFromRule(){
	Test.setCurrentPage(Page.XRuleBuilder);
	XRuleBuilderController controller = new XRuleBuilderController();
	controller.ruleName = 'test';
	controller.ruleDesc = 'Test';
	controller.selectedEntity = 'Contact';
	controller.entities_SelectedIndexChanged();
	controller.selectedScore = 'Earned Historical';
	
	controller.selectedFieldGroup = 'Contact';
	controller.fieldsGroup_SelectedIndexChanged();
	
	controller.selectedField = 'Lead Source';
	controller.fieldsList_SelectedIndexChanged();
	
	controller.selectedOp = 'in';
	
	controller.isParam1 = true;
	
	controller.addAnd();
	System.assertEquals(controller.conds.size(), 1);
	controller.conid = 0;
	controller.remove();
	System.assertEquals(controller.conds.size(), 0);
		
	}
	
	/*
	Test editing a condition and wheather it is reflected on the controls correctly
	*/
	static TestMethod void testEditCondFromRule(){
	Test.setCurrentPage(Page.XRuleBuilder);
	XRuleBuilderController controller = new XRuleBuilderController();
	controller.ruleName = 'test';
	controller.ruleDesc = 'Test';
	controller.selectedEntity = 'Contact';
	controller.entities_SelectedIndexChanged();
	controller.selectedScore = 'Earned Historical';
	controller.selectedFieldGroup = 'Contact';
	controller.fieldsGroup_SelectedIndexChanged();
	controller.selectedField = 'Lead Source';
	controller.fieldsList_SelectedIndexChanged();
	controller.selectedOp = 'in';
	controller.isParam1 = true;
	controller.addAnd();
	
	controller.selectedField = 'Deleted';
	controller.fieldsList_SelectedIndexChanged();
	controller.selectedOp = '!=';
	controller.isParam1 = true;
	controller.addAnd();
	
	System.assertEquals(controller.conds.size(), 2);
	controller.conid = 1;
	
	controller.edit();
	
	System.assertEquals(controller.conds.size(), 1);
	System.assertEquals(controller.isParam1, true);
	System.assertEquals(controller.picklist.size(), 3);
	System.assertEquals(controller.selectedField, 'Deleted');
	System.assertEquals(controller.selectedOp, '!=');
		
	}
}