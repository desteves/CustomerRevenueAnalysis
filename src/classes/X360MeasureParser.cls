public with sharing class X360MeasureParser {
	
	private final Boolean IS_JOB; // for logging
	private final String SOQL_MEASURES;
    private DateTime current; //to log when the measure was calculated  
    public X360RuleParser x360RuleParser {get; set;} //rule parser
    public string message {get; set;}

    /**
     * 
     * The constructor used by the scheduler to run all executable measures.
     * 
    **/
	public X360MeasureParser(Boolean IS_JOB){
		this.SOQL_MEASURES = X360ExecutorConstants.DEFAULT_PARSABLE_MEASURES_SOQL;
    	this.x360RuleParser = new X360RuleParser(IS_JOB);	
		this.IS_JOB = IS_JOB;
	}
	
    /**
     * 
     * If this constructor is called, then it is not a scheduled job.
     * Non-scheduled jobs have the subset feature on Contacts
     **/
	public X360MeasureParser(Id MeasureId, String groupId, Boolean IS_JOB){
		this.SOQL_MEASURES = ParsableMeasure(MeasureId);		
    	this.x360RuleParser = new X360RuleParser(groupId, IS_JOB);
		this.IS_JOB = IS_JOB;
	}
 
	/**
    *
    *	Which measure to execute from the scenarios
    *
    */
	private String ParsableMeasure(Id MeasureId)
	{
		return 'SELECT Id, Name, Definition__c, MeasureType__r.measure_type_code__c From Scenario_Measure__c WHERE Id = \'' + MeasureId + '\'';		
	}
	
   /**
     * 
     * Iterates through all measures for which the user has marked as executable
     * Upon success of executing all the measures, success is returned.
     * Otherwise, a failure page is displayed. 
     * 
    **/
    public List<X360Measure> parseMeasures()
    {  
       // List<SObject> xmlStrings = null ;  
        List<X360Measure> measures = new List<X360Measure>();    
        message = '';
        try {   
	    	// for every measure's xml rule set
	        for(SObject measureOjb: Database.query(SOQL_MEASURES)) {            	
	              
	       
            	// rules is the xml string representation  
                 string xmlRules = (string) measureOjb.get('Definition__c');     
                 //message += xmlRules + '\n\n';               
                 if (xmlRules.length() == 0)
                    continue;   
                 ID measureId = (ID) measureOjb.get('Id');
                 string measureType = '???';
                 string measureName = (string) measureOjb.get('Name');  
                 try {
	                 SObject obj = measureOjb.getSObject('MeasureType__r');
	                 measureType = (String) obj.get('Measure_Type_Code__c');		                
                 } catch (Exception e)
                 {
                 	//message += '! Error - Cannot retrieve measure type for ' + measureId + '\n\n';
            		//message += e;
                 }
                 X360Measure measure = new X360Measure(measureId, measureType, measureName);
                 measure.rules = x360RuleParser.parseRules(xmlRules);	                 
                 message += x360RuleParser.message;      
               //  message += 'Parsed ' + measure.measureType+ ' Measure: '+(string) measureOjb.get('Name') + '\n\n';
                 measures.add(measure);    
	        }           
	          //   // failed to parse the rules/measure                  	
	           //message += '! Error - Cannot parse measure: '+(string) measureOjb.get('Name') + '\n\n';       
        } catch (Exception e){
        	message += '! Error - No measure marked as executable.\n'; 
        }
        
       return measures;	  
    }
}