/**
 * classname: X360ScheduleController
 * about: Responsible for selecting measures marked as executable and scheduling
 * of  a job. It redirects the user to Salesforce page for adding/editing a job
 * and displays the current job.
 * 
**/
public  class X360ScheduleController {	
	public String message { get; set; }
	public String messageJob {get;set;}
    public id jobID;
    public id detailsId;
	public Boolean scheduled;
	public CronTrigger cronTrigger { get; set; }	//display in the visual force page
	public SelectOption[] selectedMeasures { get; set; }
    public SelectOption[] allMeasures { get; set; }
	public final string newSchedule = '/ui/setup/apex/batch/ScheduleBatchApexPage?apex_class=X360Schedulable&job_name=X360+Measure+Executor&retURL=%2Fsetup%2Fbuild%2FlistApexClass.apexp&setupid=ApexClasses';

	/**
	 * Default constructor
	 * 
	**/
	public X360ScheduleController() 
	{		
		init();
	}

	/** 
	* initialize all variables and see if theres a job in the system.
	* We only have ONE job. The measures which to execute is up to the end-user.
	*/
	private void init()
    {       
        selectedMeasures = new List<SelectOption>();
        allMeasures = new List<SelectOption>();
        try {
	        for ( Measure__c c : [SELECT Name, Id, Description__c  FROM Measure__c WHERE Executable__c = true] ) 
	        {
	            selectedMeasures.add(new SelectOption(c.Id, c.Name + ' -- ' + c.Description__c));
	        }          
        } catch (Exception e) {}    
        try {
        	for ( Measure__c c : [SELECT Name, Id, Description__c  FROM Measure__c  WHERE Executable__c = false] )
	        {
	            allMeasures.add(new SelectOption(c.Id, c.Name + ' -- ' + c.Description__c));
	        }
        } catch (Exception e) {}
        
        	/*
		Expression	Description
		0 0 13 * * ?	Class runs every day at 1 PM.
		0 0 22 ? * 6L	Class runs the last Friday of every month at 10 PM.
		0 0 10 ? * MON-FRI	Class runs Monday through Friday at 10 AM.
		0 0 20 * * ? 2010	Class runs every day at 8 PM during the year 2010.
		*/
        try 
        {
    		cronTrigger = [ SELECT  Id, TimesTriggered, NextFireTime, CronExpression,
    						CronJobDetail.Name, CronJobDetail.JobType, CronJobDetailId
				    		FROM CronTrigger 
				    		WHERE CronJobDetail.Name = :X360ExecutorConstants.DEFAULT_JOB_NAME]; 
			 jobID = cronTrigger.Id;	   
			 detailsId = cronTrigger.CronJobDetailId; 		
			 scheduled = true; 
			 messageJob = 'Found existing job ' + jobId;
        } catch (Exception e) //cronTrigger has not been scheduled
        {
        	///default values
            // https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_system.htm#apex_System_System_schedule
        	 scheduled = false;    
			 messageJob = 'Add job.';
        }
      	
    }	

	
    /**
    * User can only create a new schedule if there isnt already one
    */
    public PageReference newSchedulable() 
	{ 
		PageReference pg = null;
		messageJob = 'Already scheduled.';
		if (!scheduled) 
		{
			pg = new PageReference(newSchedule); 		
			pg.setredirect(true); 
			messageJob = 'New job being added';
			
		} else {
			deleteSchedulable();
			pg = new PageReference(newSchedule); 		
			pg.setredirect(true); 
			messageJob = 'New job being added';
		}
		return pg; 
	}
	
	/**
	 * Removes the schedule from the system, only if there.
	 * 
	**/    
	public PageReference deleteSchedulable()
	{	
		PageReference pg = null;
		messageJob = '';
		if (scheduled)
		{			
			pg = Page.X360SchedulePage;
			pg.setredirect(true); 
			messageJob = 'Job ' + jobId + ' removed.' ;					
			System.abortJob(jobID);
			scheduled = false;			
		}
		return pg; 	
	}
	
	
	/**
	 * Saves the user-selected measures which get marked as executable.
	 * These measures will execute when the time to run the schedule comes.
	 * 
	**/
	public PageReference  saveMeasures() 
	{		
		//https://www.salesforce.com/us/developer/docs/apexcode/Content/langCon_apex_SOQL_variables.htm
		message = '';
	  	List<Measure__c> updatemeasures = new List<Measure__c>();
	  	String[] Pool = new List<String>();	  	
	  	for ( SelectOption so : selectedMeasures ) 
	  	{
	  		Pool.add(so.getValue());
	  	}   
	  	     		  	  	
	  	try{
	  		for ( Measure__c m : [SELECT Id, Executable__c FROM Measure__c WHERE id     IN :Pool] ) 
		  	{
		  		if(m.Executable__c == false){
		  			m.Executable__c = true;
		  			m.Active__c = true;
		  			updatemeasures.add(m);
		  		}
		  	}	  	
        } catch (Exception e) {}
        		  	  	
	  	try{
		  	for ( Measure__c m : [SELECT Id, Executable__c FROM Measure__c WHERE id NOT IN :Pool] ) 
		  	{
		  		if(m.Executable__c == true)
		  		{
		  			m.Executable__c = false;
		  			m.Active__c = false;
		  			updatemeasures.add(m);
		  		}
		  	}	
        } catch (Exception e) {}  	
	  	try {
	  		update updatemeasures;
	  		message += 'Job updated with selected measures.' ;
	  	} catch (DmlException e) {
		    // Process exception here 
		    message = 'Failed to update job. Try again.';		    
		}  	   
		return null;
    }

}