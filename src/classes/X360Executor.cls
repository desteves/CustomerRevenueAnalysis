/**
 * classname: X360Executor
 * about: Responsible for executing all the measures marked as executable.
 * Iterate through every measure's rules; executing each one and saving the
 * results in the measure's type table.
 * It parses the xml in the definition__c field for both the measure and the rule
 * This class will also execute depending on the schedulable frequency.
 * It also parses & executes scenario measures.
 * 
**/

public class X360Executor {
	
 	//private fields
    public final Boolean IS_JOB; // for logging
    private X360ScheduleEmail x360ScheduleEmail; // for logging job results  
    private X360MeasureParser x360MeasureParser; //measure parser
    private List <ID> idList;  //current measure's rule's list of an excuted entities
    private string measureType;
    private ID measureId;
    private string measureName;
    private Datetime nowish;
    private string idEntityName;
    //public fields
    public string message {get; set;}
    public Boolean sendEmail {get; set;}
	 /**
     * 
     * The constructor used by the scheduler to run all executable measures.
     * 
    **/
    public X360Executor() 
    { 
    	idEntityName = 'Id';
    	sendEmail = true;
    	IS_JOB = true; //default value
    	x360MeasureParser = new X360MeasureParser(IS_JOB); //default value
    }

    /**
     * 
     * The constructor for this controller.
     * If this constructor is called, then it is not a scheduled job.
     * Non-scheduled jobs have the subset feature on Contacts
     **/
    public X360Executor(Id MeasureId, String groupId) 
    {   
    	sendEmail = false;
    	IS_JOB = false;    	
    	x360MeasureParser = new X360MeasureParser(MeasureId, groupId, IS_JOB);
    }        
    
    private void initEmail()      
    {  
    	string header = 'Salesforce: 360 Job Results for ' + Datetime.now().format('MM/dd/yyyy');
		string receiver = '';
    	try {    	    	
	    	receiver = [SELECT email   FROM user        WHERE id IN 
					   (SELECT OwnerId FROM CronTrigger WHERE CronJobDetail.Name = :X360ExecutorConstants.DEFAULT_JOB_NAME)
					   ].email; 
    	} catch (Exception e)
    	{	//email fails then send to current user, whomever that may be
	    	receiver = UserInfo.getUserEmail();
    	}
    	x360ScheduleEmail = new X360ScheduleEmail(receiver, 
	    								  'NatureBridge Salesforce', 
	    								  header,
	    								  'The Apex job processed the following: \n');  	    								  
	    x360ScheduleEmail.appendBody('Time: ' + System.now().getTime()/1000 + ' ms \n');    	
    }
    
    public void executeNow()
    {
    	message =  execute() ;    	
    }
     /**
     * 
     * Iterates through all measures for which the user has marked as executable
     * Upon success of executing all the measures, success is returned.
     * Otherwise, a failure page is displayed. 
     * 
    **/
    public String execute()
    {         	   
    	message = '';
    	String execMessage = '';     	
     	for (X360Measure measure: x360MeasureParser.parseMeasures())
     	{
     		measureType = measure.measureType;
     		measureId = measure.measureId;
     		measureName = measure.measureName;
     		nowish = Datetime.now();	
     		// For each rule for a particular measure, execute them and save the results. 
     		for(X360Rule rule: measure.rules)
     		{
		    	execMessage += executeRule(rule);   
     		}     		
     	}
     	
     	message += x360MeasureParser.message;
     	message += execMessage;
     	
		 if ( sendEmail )
		 {
		 	initEmail();
		 	x360ScheduleEmail.appendBody(message);
		    x360ScheduleEmail.SendNotification();
		 }		 
		 return message;
    }  
 
	/**
    *
    * Given a constructed rule, add the filtering 
    *
    */
	private String addFilter(String rule)
	{
		//SELECT Id FROM Contact WHERE Id in (SELECT Contact_ID__c FROM Group_Member__c WHERE Id = 'a19f0000003nSyK') GROUP BY Id HAVING COUNT(Id) = 1 LIMIT 1
    	//SELECT Id FROM Contact WHERE firstname = 'Diana' AND lastname= 'Esteves' AND Id in (SELECT Contact_ID__c FROM Group_Member__c WHERE Id = 'a19f0000003nSyK')
		String newRule = '';
		List<String> rulewords = rule.split(' ');		
		Integer indxWhere = rule.toUpperCase().indexOf(' WHERE ');
		idEntityName = rulewords.get(1);
 					//if (idEntityName.endswith('__c')) 
 					//	idEntityName = idEntityName.replace('__c', '__r.Id'); 
 					//message += 'idEntityName ' + idEntityName;
		if (indxWhere != -1 ) { // has WHERE, append expression under this clause 
			rulewords.add(5, rulewords.get(1) + x360MeasureParser.x360RuleParser.SOQL_LIST + ' AND');	
		} else { // no WHERE, insert after FROM caluse
			rulewords.add(4,  'WHERE '  + rulewords.get(1) + x360MeasureParser.x360RuleParser.SOQL_LIST);	
		}
		
		for (String s: rulewords)
		{
			newRule+=' ' + s;			
		}
		
		return newRule;
	}
	
		
	/**
     * 
     * Executes one rule and save the entity's Ids to be later added.
    **/
    public string executeRule (X360Rule rule) 
    {        
    	string message = '';       
       	if(!IS_JOB) 
        	rule.query = addFilter(rule.query).trim();       
    	try {      
		    //empty any older ids 
		    idList = new List<ID>();
		    //the results for the executed rule 	
		    List<SObject> hits  = 	Database.query(rule.query);
		    if (hits == null || hits.isEmpty())
		    {
		    	 message += 'Rule ' + rule.name +' ('+rule.id+') had no hits\n\n';
		    	
		    } else {
			    for(SObject i: hits) {
			         idList.add( (Id) i.get(idEntityName)); 
			    } // end for
			    message += 'Executed Rule ' + rule.name +' ('+rule.id+') with ' + idList.size() + ' hit(s). \n';
			    message += addScore(rule);
		    }
		} catch (Exception e )
		{
		    //bad query
		    message += '! Error - Bad rule composition ' + rule.name +' ('+rule.id+')\n\n';
		}
		return message;
    }
    
    /**
     * 
     * Checks the measure for which the rule belongs and adds it to the proper table
     * 
    **/
    public string addScore(X360Rule rule)
    {
    	string message = '';       
        
        String measureTable = (!IS_JOB ? X360ExecutorConstants.SCENARIO_TABLE : 
                        measureType.equals(X360ExecutorConstants.ACCOUNT_HISTORICAL_EARNED        ) ? X360ExecutorConstants.ACCOUNT_HISTORICAL_EARNED_TABLE :
        				measureType.equals(X360ExecutorConstants.ACCOUNT_HISTORICAL_CONTRIBUTED   ) ? X360ExecutorConstants.ACCOUNT_HISTORICAL_CONTRIBUTED_TABLE :  
        				measureType.equals(X360ExecutorConstants.ACCOUNT_POTENTIAL_CONTRIBUTED    ) ? X360ExecutorConstants.ACCOUNT_HISTORICAL_CONTRIBUTED_TABLE : 
        				measureType.equals(X360ExecutorConstants.ACCOUNT_POTENTIAL_EARNED         ) ? X360ExecutorConstants.ACCOUNT_HISTORICAL_CONTRIBUTED_TABLE :
        				measureType.equals(X360ExecutorConstants.CONTACT_HISTORICAL_CONTRIBUTED   ) ? X360ExecutorConstants.CONTACT_HISTORICAL_CONTRIBUTED_TABLE :
        				measureType.equals(X360ExecutorConstants.CONTACT_POTENTIAL_CONTRIBUTED    ) ? X360ExecutorConstants.CONTACT_POTENTIAL_CONTRIBUTED_TABLE :      				
        				measureType.equals(X360ExecutorConstants.CONTACT_POTENTIAL_EARNED         ) ? X360ExecutorConstants.CONTACT_POTENTIAL_EARNED_TABLE :
        				measureType.equals(X360ExecutorConstants.CONTACT_HISTORICAL_EARNED        ) ? X360ExecutorConstants.CONTACT_HISTORICAL_EARNED_TABLE :
        				measureType.equals(X360ExecutorConstants.CONTACT_TIER                     ) ? X360ExecutorConstants.CONTACT_TIER_TABLE : '???' ); //last option  
        //String objectAPIName = idList[0].getSObjectType().getDescribe().getName();
        Boolean isContact =  X360ExecutorConstants.CONTACT_TYPES.contains(measureType);// objectAPIName.equals('Contact') ; 
        Boolean isAccount =  X360ExecutorConstants.ACCOUNT_TYPES.contains(measureType);// objectAPIName.equals('Account') ;
        Boolean isScenario = measureTable.equals(X360ExecutorConstants.SCENARIO_TABLE);
		Datetime n = Datetime.now();			
        if (measureTable.equals('???'))
        {
        	message += measureType + ' Not yet implemented.\n\n';         	
        } else if (measureTable.equals(X360ExecutorConstants.CONTACT_TIER)) {
        	/*
        	List<Contact> cons = new List<Contact>();
	    	for(ID objId: idList)
	        {	//need to get the contact id so we can update the right fields
	        	Contact con = [SELECT ID, Tier_ID__c FROM Contact WHERE ID = :objId ];	        		       
		        //con.Tier_ID__c = (ID) rule.score;   
		        cons.add(con);     
	        }      
	        try { //support limits 10k?	
 	   			if (!cons.isEmpty()) {
	            	update cons;    
	            	message += measureType +' Tier updated succesfully ('+  math.abs(DateTime.now().getTime() - n.getTime()) + ' ms) .\n\n'; 
 	   			}
	        } catch (DmlException e)
	        {   
	            message += measureType +' Measure failed to insert.\n\n';
	        } */
    	}else {					
        	Integer iScore = 0;
	        try { 
	    		iScore = Integer.valueOf(rule.score);  
	        } catch (Exception e) { 
	        	message += '! Error - Cannot retrieve score for ' +  rule.id + '\n';
	        }  
			List<sObject> newMeasures = new List<sObject>();
	         if(IS_JOB && !isScenario) {	         	
	 		    for(ID objId: idList)
	            { 
	            	sObject measure = Schema.getGlobalDescribe().get(measureTable).newSObject(); 	       
	            	measure.put('Name', measureType + ' Autocalculated');   
	            	measure.put('Score__c', iScore);
	            	measure.put('Measure_Id__c', measureId);
	            	measure.put('Rule__c', rule.id);
	            	measure.put('calc_dt__c', nowish);	            	  	
	                if (isContact) {
	                	measure.put('Contact_ID__c', objId);
		            } else if (isAccount) {
		            	measure.put('Account__c', objId);		            	
		            } 		else { 
 					            	message += '! Error - Unknown measure type. '; 
 					            }            
	                newMeasures.add(measure);          
	            }
	         } else if (isScenario) {
	         	
	         	for(ID objId: idList)
	            { 
		         	sObject measure = Schema.getGlobalDescribe().get(measureTable).newSObject();      
	            	measure.put('Name', measureType + ' Autocalculated');   
	            	measure.put('Score__c', iScore);
	            	measure.put('Scenario_Measure__c', measureId);
	            	measure.put('Rule_ID__c', rule.id);
	            	measure.put('calculation_date__c', nowish);
		            measure.put('Contact_ID__c', objId); 
		            
		            newMeasures.add(measure);  
	            }
	         }
	         
	 	   	try { //support limits 10k?
	 	   		
	 	   		if (!newMeasures.isEmpty()) {
	            	insert newMeasures;    
	            	message += measureName + ' (' + measureType +') Measure inserted succesfully ('+  math.abs(DateTime.now().getTime() - nowish.getTime()) + ' ms) .\n\n'; 
	 		 	}
	        } catch (DmlException e)
	        {   
	            message += measureType +' Measure failed to insert.\n\n';
	        }
	   }  
       return message;                     
    }		
}