public with sharing class X360RuleParser {

	private final Boolean IS_JOB; // for logging
    public final String SOQL_LIST {get; set;}
    public string message {get; set;}

	public X360RuleParser(Boolean IS_JOB) {
		this.SOQL_LIST = null;
		this.IS_JOB = IS_JOB;
	}
	
	public X360RuleParser(String groupId, Boolean IS_JOB) {
		SOQL_LIST = ParsableList(groupId);
		this.IS_JOB = IS_JOB;
	}
	/**
    *
    * Which entities to apply the measure
    *
    */
	private String ParsableList(String groupId)
	{
		return ' IN (SELECT Contact_ID__c FROM Group_Member__c WHERE Group_Id__c = \'' + groupId + '\')';		
	}
	     
    /**
     * 
     * For a given measure, it extracts all the rules contained within 
     * 
     * 
    **/
    public List<X360Rule> parseRules (string xmlRules)
    {
    	message = '';
    	List<X360Rule> ruleList = new List<X360Rule>();   //current measure's rules
        //<Rules><Rule ID="a14f0000001ECuYAAW" Score="20"><Params><Param id="P001">CMU</Param></Params></Rule></Rules>
        XmlStreamReader xsrMeasure = new XmlStreamReader(xmlRules);     
        // iterate through the rules for the current measure
        while(xsrMeasure.hasNext())
        {           
            //  Start at the beginning of the rule and make sure that it is a rule                  
            if(xsrMeasure.getEventType() == XmlTag.START_ELEMENT) 
            {
                if('Rule' == xsrMeasure.getLocalName()) 
                {
                    //  Pass the rule to the parseRule method (below)
                    X360Rule r = parseRule(xsrMeasure);                 
                    if (r != null) 
                    {
                        ruleList.add(r); 
                    }
                }
            }
            xsrMeasure.next();
        } // end while
        return ruleList;
    }
        
   
	 /**
     * 
     * For each rule, parse it by populating the fields in the Rule class.
     * Parse through the XML
     * 
    **/
    private X360Rule parseRule(XmlStreamReader reader)
    {	
        X360Rule rule = new X360Rule();    
        //message += reader.toString() + '\n';         
        //extract the attributes for the current rule
        rule.id = reader.getAttributeValue(null, 'ID');
        rule.score = reader.getAttributeValue(null, 'Score');          
        //iterate through the param for this rule
        while(reader.hasNext())
        {            
        	//its a new param
            if('Param' == reader.getLocalName()  && reader.getEventType() == XmlTag.START_ELEMENT)
            {
                X360Param param = new X360Param();
                param.id = reader.getAttributeValue(null, 'id');
                reader.next();
                if (reader.isCharacters())
                {
                    param.value = reader.getText();
                    rule.params.add(param); 
                    continue;
                }
            }
            //reached the end of the rule, done parsing.
            if('Rule' == reader.getLocalName() && reader.getEventType() == XmlTag.END_ELEMENT)
            {
                break; 
            }           
           
            reader.next();
        }
           
		try {
			//get the rule by looking up its id  
			//message += 'Parsing '+ rule.id + '\n';
			Rule__c r = [SELECT Name, Definition__c, Description__c From Rule__c WHERE id = :rule.id limit 1];
			rule.name = r.Name;
     		rule.description = r.Description__c;
     		String XML = r.Definition__c;
	        Dom.Document doc = new Dom.Document();
	        doc.load(XML);
	        rule.query = doc.getRootElement().getChildElement('Query', null).getText();	        
	        //query has been parsed, construct
	        rule.query = rule.constructRule(); 			
     		
	  	} catch (Exception e)
        {   //failed to execute the rule
        	message += '! Error - Cannot parse rule ' + rule.name + '(' + rule.id + ')\n\n';
        }
        return rule;
    }
    
}