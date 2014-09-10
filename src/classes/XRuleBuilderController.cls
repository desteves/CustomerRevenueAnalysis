public with sharing class XRuleBuilderController {
    
    public  SelectOption[] entities {get; set;}
    public  SelectOption[] scoreTypes {get; set;}
    public  SelectOption[] fieldsList {get; set;}
    public  SelectOption[] fieldsGroup {get;set;}
    public  SelectOption[] operations {get;set;}
    public  SelectOption[] aggregations {get;set;}
    public  SelectOption[] picklist{get;set;}
    
    public String selectedEntity {get;set;}
    public String selectedFieldGroup {get;set;}
    public String selectedScore {get;set;}
    public String selectedField {get;set;}
    public String selectedOp {get;set;}
    public String selectedFn {get;set;}
    public String selectedPickListItem {get;set;}
    public String ruleName {get;set;}
    public String ruleDesc {get;set;}
    public String param1 {get;set;}
    public String status {get;set;}
    public String debug {get;set;}
    public Boolean isParam1 {get;set;}
    public integer numPicklist {get;set;}
    public Boolean isDate {get;set;}
    public Boolean isPickList {get;set;}
    public Boolean isBool {get;set;}
    public Boolean isAnd {get;set;}
    public List<CondDetails> conds {get;set;}
    public integer conid {get;set;}
    
    private final List<String> numberDateOps = new List<String>{'>', '<', '!=', '='};
    private final List<String> stringOps = new List<String>{'Like', 'in', '!=', '='};
    private final List<String> pickListOps = new List<String>{'in', '!=', '='};
    private final List<String> booleanOps = new List<String>{'='};
    private final List<String> aggNumbFns = new List<String>{'Count', 'Sum', 'Max', 'Min', 'Avg'};
    private final List<String> aggNotNumFns = new List<String>{'Count'};
    private final List<String> accScores = new List<String>{'Earned Historical', 'Earned Potential'};
    private final List<String> contactScores = new List<String>{'Contributed Historical', 'Contributed Potential', 'Earned Historical', 'Earned Potential','Tier'};
    private final List<String> boolVal = new List<String>{'true', 'false'};
    private final String DEFAULT_SELECT = '-- Select --';
    private Map<String, FieldDetails> fieldType = new Map<String, FieldDetails>();
    private integer numbOfConds = 0;
    private Boolean debuggingMode = false;
    
    
    public XRuleBuilderController()
    {
        init();   
    }
    
    /*
    Initialize the variables of the class
    */
    public void init()
    {
    	selectedEntity = DEFAULT_SELECT;
    	conds = new List<CondDetails>();
    	
    	isAnd = false;
    	ruleDesc = '';
    	ruleName = '';
    	debug = '';
    	
        entities = new SelectOption[]{};
        entities.add(new Selectoption(DEFAULT_SELECT,DEFAULT_SELECT));
        entities.add(new Selectoption('Account','Account'));
        entities.add(new SelectOption('Contact','Contact'));
        
        entities_SelectedIndexChanged();
    }
    
    /*
    this function displays all the objects associated with the selected entity
    */
    private void processSchemaInfo(string entityName)
    {
    	Schema.DescribeSObjectResult objDescribe;
        Schema.SObjectType objType = SchemaManager.getObjectSchema(entityName);
        
        if(objType!=null){
	        objDescribe = objType.getDescribe(); 
	        
	        List<Schema.ChildRelationship> chlist = objDescribe.getChildRelationships();
	        for(Schema.ChildRelationship sof : chlist){
		    	fieldsGroup.add(new SelectOption(sof.getChildSObject()+','+sof.getField(),
		    	 sof.getChildSObject()+''));
		    }
		    fieldsGroup.sort();
        }
    }
    
    /*
    A handler for a page action, sets the appropriate score types and field groups based on
    the selected entity
    */
    public void entities_SelectedIndexChanged()
    {
    	cleanMainControls();
    	cleanDetailsControls(true);
    	
    	if(selectedEntity!=null && selectedEntity!='' && selectedEntity!=DEFAULT_SELECT){
        	processSchemaInfo(selectedEntity);
        		
	    	if(selectedEntity.equals('Account'))
	    		populateSelectOptions(scoreTypes, accScores);
	    	else if(selectedEntity.equals('Contact'))
	    		populateSelectOptions(scoreTypes, contactScores);
	    		
	    	fieldsGroup_SelectedIndexChanged();
    	}
    }
    
    /*
    Takes a list and a refrence for SelectOption array and populate it with the list
    */
    private void populateSelectOptions(SelectOption[] options, List<String> items){
    	for(String name: items)
    		options.add(new SelectOption(name, name));
    }
    
   /*
   cleans all the drop down lists and controls in the main form
   */
   private void cleanMainControls(){
   		fieldsGroup = new SelectOption[]{};
    	scoreTypes = new SelectOption[]{};
    	
    	scoreTypes.add(new Selectoption(DEFAULT_SELECT,DEFAULT_SELECT));
        fieldsGroup.add(new Selectoption(DEFAULT_SELECT,DEFAULT_SELECT));
    	
    	selectedScore = DEFAULT_SELECT;
    	selectedFieldGroup = DEFAULT_SELECT;
   }
   
   /*
   cleans all the drop down lists and controls in the details form. If true it 
   cleans the fields list too, otherwise it keeps them as is
   */
   private void cleanDetailsControls(boolean cleanFields){
   		if(cleanFields){
   			fieldsList = new SelectOption[]{};
   			fieldsList.add(new Selectoption(DEFAULT_SELECT,DEFAULT_SELECT));
    		selectedField = DEFAULT_SELECT;
   		}
   		
    	operations = new SelectOption[]{new Selectoption(DEFAULT_SELECT,DEFAULT_SELECT)};
    	aggregations = new SelectOption[]{new Selectoption(DEFAULT_SELECT,DEFAULT_SELECT)};
    	picklist = new SelectOption[]{new Selectoption(DEFAULT_SELECT,DEFAULT_SELECT)};
    	
    	selectedOp = DEFAULT_SELECT;
    	selectedFn = DEFAULT_SELECT;
    	selectedPickListItem = DEFAULT_SELECT;
    	
    	param1 = '';
    	isDate = false;
    	isPickList = false;
    	isBool = false;
   }
   
    /*
    A handler for a page action, This function list all the fields in the selected sub-entity 
    e.g. Contact.Prog_Part. fields
    */
    public void fieldsGroup_SelectedIndexChanged(){
    	cleanDetailsControls(true);
    	string[] objAtt= selectedFieldGroup.split(',');
    	fieldType = new Map<String, FieldDetails>();
        Schema.SObjectType objType = SchemaManager.getObjectSchema(objAtt[0]);
        
        if(objType!=null){
		    Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
		    for(Schema.SObjectField field: fieldMap.Values()){
		    	Schema.DescribeFieldResult fieldDesc = field.getDescribe();
		    	FieldDetails fd = new FieldDetails(fieldDesc.getLabel(),
		    		 fieldDesc.getLocalName(), fieldDesc.getType()+'');
		    		 
		    	// if the field type is one of those it wont be added to the displayed list
		    	if(!fd.Type.equals('REFERENCE') && !fd.Type.equals('ID')
		    		&& !fd.Type.equals('URL') && !fd.Type.equals('BASE64')
		    		&& !fd.Type.equals('ANYTYPE')){
			    	fieldsList.add(new SelectOption(fd.Name, fd.Name));
			    	fieldType.put(fd.Name, fd);
			    	if(fd.Type.equals('PICKLIST')){
			    		for(Schema.Picklistentry entry: fieldDesc.getPickListValues())
			    			fd.Values.add(entry.getValue());
			    	}
		    	}
		    }
		    fieldsList.sort();
        }
    }
    
    /* A handler for a page action, This function set the operation and 
    the format of the values based on the selected field type
    */
    public void fieldsList_SelectedIndexChanged(){
    	cleanDetailsControls(false);
    	
    	FieldDetails fd = fieldType.get(selectedField);
    	if(fd.Type.equals('STRING') ||
    		fd.Type.equals('TEXTAREA')){
    		populateSelectOptions(operations, stringOps);
    		populateSelectOptions(aggregations, aggNotNumFns);
    		isDate = false;
    		isPickList = false;
    	}
    	else if(fd.Type.equals('BOOLEAN')){
    		populateSelectOptions(operations, booleanOps);
    		populateSelectOptions(aggregations, aggNotNumFns);
    		populateSelectOptions(picklist, boolVal);
    		isDate = false;
    		isPickList = false;
    		isBool = true;
    	}
    	else if(fd.Type.equals('DOUBLE') ||
    			fd.Type.equals('INTEGER') ||
    			fd.Type.equals('CURRENCY')||
    			fd.Type.equals('PERCENT')){
    		populateSelectOptions(operations, numberDateOps);
    		populateSelectOptions(aggregations, aggNumbFns);
    		isDate = false;
    		isPickList = false;
    			}
    	else if(fd.Type.equals('DATE') ||
    			fd.Type.equals('DATETIME')){
    		populateSelectOptions(operations, numberDateOps);
    		populateSelectOptions(aggregations, aggNotNumFns);
    		isDate = false;
    		isPickList = false;
    			}
    	else if(fd.Type.equals('PICKLIST')){
    		populateSelectOptions(operations, pickListOps);
    		populateSelectOptions(aggregations, aggNotNumFns);
    		populateSelectOptions(picklist, fd.Values);
    		
    		numPicklist = fd.Values.size();
    		isDate = false;
    		isPickList = true;
    		isBool = false;
    	}
    	else{ 
    		param1 = selectedField+'; Type: '+ fd.Type;
    	}
    }
    
    /* 
    A handler for a page action, change the operations based on the selected 
    aggregation function
    */
    public void aggregiations_SelectedIndexChanged(){
    	if(!selectedFn.equals(DEFAULT_SELECT)){
    		if(selectedFn.equals('Sum') || selectedFn.equals('Count')){
    			operations = new SelectOption[]{};
    			operations.add(new Selectoption(DEFAULT_SELECT,DEFAULT_SELECT));
    			selectedOp = DEFAULT_SELECT;
    			isPickList = false;
    			isBool = false;
    			populateSelectOptions(operations, numberDateOps);
    		}
    	}
    	else{
    		fieldsList_SelectedIndexChanged();
    	}
    }
    
    /* 
    A handler for a page action, it parses a condition entered by the user and
    add it to the conditions list
    */
    public void addAnd(){
    	CondDetails cond = addCondToList('AND');
    	if(cond!=null){
	    	//debug = debug+'\r\n'+cond.stringFormat();
	    	numbOfConds++;
	    	fieldsGroup_SelectedIndexChanged();
	    	isAnd = true;
    	}
    }
    
    /*
    builds a condition object and add it to the conditions list
    */
    private CondDetails addCondToList(string operand){
    	if(isParamPopulated()){
	    	CondDetails cond = new CondDetails();
	    	cond.operand = operand;
	    	cond.isAggregate = !selectedFn.equals(DEFAULT_SELECT);
	    	cond.isParam = isParam1;
	    	cond.fd = fieldType.get(selectedField);
	    	cond.operation = selectedOp;
	    	cond.function = selectedFn;
	    	cond.value = isPicklist ? selectedPicklistItem : param1;
	    	cond.fnVals = aggregations;
	    	cond.opVals = operations;
	    	cond.picklistVals = isPicklist||isBool ? picklist : null;
	    	cond.id = numbOfConds;
	    	conds.add(cond);
	    	return cond;
    	}
    	else{
    		status = 'Please fill all the required fields';
    		return null;
    	}
    }
    
    /* 
    A handler for a page action, it parses the parameters entered by the user to 
    a rule and save it to the DB
    */
    public void save(){
    	addCondToList('AND');
    	if(conds.size()>0){
    		String query = buildQueryString();
    		String xml = buildXml(query);
	        saveRule(xml);
	        //status = xml; // for debug purposes
    	}
    	else
    	{
    		status = 'There is nothing to save';
    		//debug = status;
    	}
    	init();
    }
    
    /* 
    saves a rule to the Rule Custom Object
    */
    private void saveRule(String xml){
    	Rule__c newRule = new Rule__c();
        
        newRule.Description__c = ruleDesc;
        newRule.Name = ruleName;
        newRule.Definition__c = xml;
        newRule.Type__c = selectedEntity;
        //debug = xml;
        try{
        	insert newRule;
        	status = 'Saved Successfully. ';
        	//debug = query;
        	
        }
        catch(Exception e){
        	status = 'There was an error saving this rule';
        	//debug = query;
        }
    }
    
    /* 
    starts constructing the query for the specified rule
    */
    private String buildQueryString(){
    	String q = '';
    	String col = '';
    	String table = '';
    	String cond = '';
    	String aggCond = '';
    	string[] objAtt= selectedFieldGroup.split(',');
    	// set the name of the column to be selected
    	if(!selectedEntity.equals(DEFAULT_SELECT)){
    		if(selectedEntity.equals('Account')){
    			// if it is the same table then ID otherwise..
    			if(objAtt[0].equals('Account'))
    				col = 'ID';
    			else{
					col = objAtt[1].replace('__c', '__r.Id');
    			}
    		}
    		else{
    			if(objAtt[0].equals('Contact'))
    				col = 'ID';
    			else{
					col = objAtt[1].replace('__c', '__r.Id');
    			}
    		}
    	}
    	table = objAtt[0];
    	
    	//FieldDetails fd = fieldType.get(selectedField);
    	cond = buildCondition(col);
    	q = 'SELECT ' + col + ' FROM ' + table + cond;
    	writeDebug(q);
    	return q;
    }
    
    /* 
    builds the XML of the rules to be saved
    */ 
    private String buildXml(String query){
    	XmlStreamWriter w = new XmlStreamWriter();
			w.writeStartDocument(null,'1.0');
			w.writeStartElement(null,'Rule',null);
			  w.writeAttribute(null, null, 'name', ruleName);
			  w.writeAttribute(null, null, 'entity', selectedEntity);
			  w.writeAttribute(null, null, 'type', selectedScore);
			
			w.writeStartElement(null,'Desc',null);
			  w.writeCharacters(ruleDesc);
			w.writeEndElement();
			
			
			integer numOfop = 1;
			w.writeStartElement(null,'Params',null);
			for(CondDetails c: conds){
				
				if(c.isParam){
					w.writeStartElement(null,'Param',null);
					  w.writeAttribute(null, null, 'id', 'P0'+c.id);
					  if(c.isAggregate){
				        w.writeAttribute(null, null, 'fun', c.function);
				      }
				      w.writeAttribute(null, null, 'Datatype', c.fd.Type);
					  w.writeAttribute(null, null, 'multiple', (c.picklistVals != null)+'');
					  if(!c.operation.equals(DEFAULT_SELECT)){
					  	w.writeAttribute(null, null, 'operator', c.operation);
					  }
					  if(c.picklistVals!=null){
					  	w.writeStartElement(null,'Values',null);
					  		writeValues(w, c.picklistVals);
					  	w.writeEndElement();
					  }
					w.writeEndElement();
					// if the operation is not set then put it as a param
					if(c.operation.equals(DEFAULT_SELECT)){
						w.writeStartElement(null,'Param',null);
					  		w.writeAttribute(null, null, 'id', 'O0'+numOfOp);
					  		numOfOp++;
					  		w.writeAttribute(null, null, 'Datatype', 'PICKLIST');
					  		w.writeStartElement(null,'Values',null);
					  			writeValues(w, c.opVals);
					  		w.writeEndElement();
						w.writeEndElement();
					}
				}
			}
			w.writeEndElement();
			
			w.writeStartElement(null,'Query',null);
			  w.writeCharacters(query);
			w.writeEndElement();
			
			w.writeEndElement();
			
			w.writeEndDocument();
			string xml = w.getXmlString();
			w.close();
			return xml;
    }
    
    /* 
    Transfer an array of SelectOptions to an XML with array values as elements
    */
    private void writeValues(XmlStreamWriter w, SelectOption[] values){
    	for(SelectOption val: values){
    		if(!val.getLabel().equals(DEFAULT_SELECT)){
	    		w.writeStartElement(null,'value',null);
				  w.writeCharacters(val.getLabel());
				w.writeEndElement();
    		}
    	}
    }
    
    /*
    This function build the condition string based on the field type and the selected operator
    */
    private String buildCondition(string col){
    	String cond = '';
    	List<String> whereParts = new List<String>();
    	List<String> havingParts = new List<String>();
    	integer numOfOp = 1;
    	for(CondDetails c: conds){
    		String paramVal = '';
			String op = '';
    		string condStr = '';
    		if(c.isParam){
    			paramVal = 'P0'+c.id;
	    	}
	    	else{
	    		paramVal = c.value;
	    	}
	    	if(c.operation.equals(DEFAULT_SELECT)){
	    		op = 'O0'+numOfOp;
	    		numOfOp++;
	    	}
	    	else{
	    		op = c.operation;
	    	}
	    	
	    	if(c.isAggregate){
	    		condStr = buildHavingCondition(c.function, op, paramVal);
	    		havingParts.add(c.operand+ ' ' +condStr);
	    	}
	    	else{
	    		condStr = buildWhereCondition(c.fd, op, paramVal, c);
	    		whereParts.add(c.operand+ ' ' +condStr);
	    	}
    	}
    	
    	if(whereParts.size()>0){
    		cond = ' WHERE ';
    		for(string w: whereParts){
    			cond = cond + ' '+w;
    		}
    		cond = cond.replaceFirst('AND','');
    	}
    	if(havingParts.size()>0){
    		string hav = ' GROUP BY '+ col +' HAVING ';
    		for(string h: havingParts){
    			hav = hav + ' '+h;
    		}
    		hav = hav.replaceFirst('AND','');
    		cond = cond + hav;
    	}
    	return cond;
    }
    
    /* 
    this function build the HAVING part of the query based on the params provided
    */
    private String buildHavingCondition(String fn, String op, String paramVal){
    	string cond = '';
    	cond = fn +'(ID) '+ op+' '+ paramVal;
    	
    	return cond ;
    }
    
    /* 
    this function build the WHERE part of the query based on the condition provided
    */
    private String buildWhereCondition(FieldDetails fd, String op, String paramVal, CondDetails c){
    	string cond = '';
    	if(fd.Type.equals('DATE') ||
    		fd.Type.equals('DOUBLE') ||
    		fd.Type.equals('INTEGER') ||
    		fd.Type.equals('BOOLEAN')||
    		fd.Type.equals('CURRENCY')||
    			fd.Type.equals('PERCENT')){
    		cond = fd.Identifier +' '+ op+' '+ paramVal;
    	}
    	else if (fd.Type.equals('DATETIME')){
    		cond = 'DAY_ONLY('+fd.Identifier +') '+ op+' '+ paramVal;
    	}
    	else if(fd.Type.equals('STRING') ||
    			fd.Type.equals('TEXTAREA')){
    		if(op.equals('LIKE'))
    			paramVal = '%'+paramVal+'%';		
    		cond = fd.Identifier +' '+ op+' \''+ paramVal+'\'';
    	}
    	else if (fd.Type.equals('PICKLIST')){
    		if(c.isParam){
    			cond = fd.Identifier +' '+ op+'('+ paramVal+')';
    		}
    		else{
	    		c.value = c.value.replace(DEFAULT_SELECT, '');
	    		c.value = c.value.replace('[', '');
	    		c.value = c.value.replace(']', '');
	    		String paramList ='';
	    		for(String param : c.value.split(','))
	    		{
	    			if(!param.equals('')){
	    				paramList = paramList+ ',\'' +param+ '\'';
	    			}
	    		}
	    		paramList = paramList.replaceFirst(',', '');
	    		cond = fd.Identifier +' '+ op+'('+ paramList+')';
    		}
    	}
    	return cond;
    }
    
    /* 
    Check if the required fields are populated to save the rule or not
    */
    private boolean isParamPopulated(){
    	return !ruleName.equals('') && !ruleDesc.equals('')
    	&& !selectedEntity.equals(DEFAULT_SELECT) && !selectedScore.equals(DEFAULT_SELECT)
    	&& !selectedFieldGroup.equals(DEFAULT_SELECT) && !selectedField.equals(DEFAULT_SELECT)
    	&& (isParam1 || !param1.equals('') || !selectedPickListItem.equals(DEFAULT_SELECT));
    }
    
    /* 
    A handler for a page action, This function parse the clikced condition on the page's control to enable editing
    */
    public void edit()
    {
    	CondDetails c = findCond(conid);
    	if(c != null){
			selectedField = c.fd.Name;
			aggregations = c.fnVals;
			selectedFn = c.function;
			operations = c.opVals;
			selectedOp = c.operation;
			param1 = c.value;
			isPicklist = c.picklistVals != null;
			picklist = c.picklistVals;
			isParam1 = c.isParam;
			removeCondFromList(c.id);
    	}
    	else{
    		debug = 'canot find id: '+ conid;
    	}
    }
    
    /* 
    A handler for a page action, This function removes the clikced condition from the rule def
    */
    public void remove()
    {
		removeCondFromList(conid);
    }
    
    /*
    a helper function to remove a condition and updates the IDs
    */
    private void removeCondFromList(integer id){
    	conds.remove(id);
    	numbOfConds = 0;
    	for(CondDetails c : conds){
    		c.id = numbOfConds++;
    	}
    }
    
    /*
    find a condition based on its id from the list of conditions
    */
    private CondDetails findCond(integer id){
    	CondDetails retVal = null;
    	for(CondDetails c : conds){
    		if(c.id == id)
    			retVal = c;
    	}
    	return retVal;
    }
    
    /*
	helper function to display the passed messages. If the debuggingMode is set to false,
	nothing will be displayed.
	*/
	private void writeDebug(string msg){
		if(debuggingMode)
			debug = msg;
	}
    
    /*
    This calss holds info about an attribute of a Custom Object
    */
    public class FieldDetails{
		public string Name {get;set;}
		public string Identifier {get;set;}
		public string Type {get;set;}
		public string[] Values {get;set;}
		
		public FieldDetails(string name, string identifier, string type){
    		this.Name = name;
    		this.Identifier = identifier;
    		this.Type = type;
    		this.Values = new string[]{};
    	}
    }
    
    /*
    This class holds all the condition params and values
    */
    public class CondDetails{
    	public integer id {get;set;}
    	public string operand {get;set;}
    	public boolean isAggregate {get;set;}
    	public boolean isParam {get;set;}
		public FieldDetails fd{get;set;}
		public string operation {get;set;}
		public string value {get;set;}
		public string function {get;set;}
		public string condStr{
			get{
				return stringFormat();}
			}
		public SelectOption[] fnVals {get;set;}
		public SelectOption[] opVals {get;set;}
		public SelectOption[] picklistVals {get;set;}
		public String stringFormat(){
			string att = '';
			if(!isAggregate){
				att = fd.Name;
			}
			else{
				att = function+'('+fd.Name+')';
			}
			return att + ' '+(operation.equals('-- Select --')? '[??]': operation)+ 
			' '+ (isParam? '[??]':value) +' '+operand;
		}
    }
}