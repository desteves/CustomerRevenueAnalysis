public class XScoresQuadrantsController {
	public class Score{
    	public Integer Score {get; set;}
    	public Datetime CalcDate {get; set;}
    	public String CalcDateOnly {get; set;}
    	
    	public Score(Integer score, Datetime calcDate){
    		this.Score = score;
    		this.CalcDate = calcDate;
    		
    		this.CalcDateOnly = this.CalcDate.month()+'/'+CalcDate.day()+'/'+CalcDate.year();
    	}
    	public Score(){
    		this.Score = 0;
    	}
    }
    
	// instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    // the actual contact
    public Contact c {get; set;}
    
    // the possible scores for this contact
    public Score historicalEarnedScore {get;set;}
    public Score historicalContributedScore {get;set;}
    public Score potentialEarnedScore {get;set;}
    public Score potentialContributedScore {get;set;}
    // this to style the tier part of the page
    public string tier {get;set;}
    public string color {get;set;}
    public string textColor {get;set;}
    
    public XScoresQuadrantsController(ApexPages.StandardController controller) {
        //initialize the stanrdard controller
        this.controller = controller;
        this.c = (Contact)controller.getRecord();
        // this query needed to load the value of the tier name otherwise it is null
        c = [SELECT id, Name, Tier_Id__r.Name__c, Tier_Id__r.text_color__c, Tier_Id__r.background_color__c
        	 FROM Contact WHERE ID = :c.Id];
        init();
    }
    
    private void init(){
    	getTier();
    	getScores();
    }
    
    /*
    based on the tier name, set the back and fore color for the tier name
    */
    private void getTier(){
    	if(c.Tier_Id__c != null){
    		tier = c.Tier_Id__r.Name__c;
    		textColor = c.Tier_Id__r.text_color__c+';';
			color = c.Tier_Id__r.background_color__c+';';
			}
			else
				color = 'white;';//'FFFFFF';
    }
    
    /*
    retrives all the scores and thier calculation date associated with contact.
    It gets the latest score for the currently active measure.
    */
    private void getScores(){
    	List<Contributed_Score__c> results2 = 
    		[SELECT Score__c, Calc_DT__c
    		 FROM Contributed_Score__c
    		 WHERE contact_ID__c = :c.id AND measure_Id__r.Active__c = true
    		 ORDER BY Calc_DT__c DESC LIMIT 1];
    	
    	if(results2.size()>0){
    		historicalContributedScore = new Score(Integer.valueOf(results2.get(0).Score__c), results2.get(0).Calc_DT__c);
    	}
    	else{
    		historicalContributedScore = new Score();
    	}
    	
    	List<Earned_Score__c> results1 = 
    		[SELECT Score__c, Calc_DT__c
    		 FROM Earned_Score__c
    		 WHERE contact_ID__c = :c.id AND measure_Id__r.Active__c = true
    		 ORDER BY Calc_DT__c DESC LIMIT 1];
    	
    	if(results1.size()>0){
    		historicalEarnedScore = new Score(Integer.valueOf(results1.get(0).Score__c), results1.get(0).Calc_DT__c);
    	}
    	else{
    		historicalEarnedScore = new Score();
    	}
    	
    	List<Potential_Earned_Score__c> results4 = 
    		[SELECT Score__c, Calc_DT__c 
    		 FROM Potential_Earned_Score__c
    		 WHERE contact_ID__c = :c.id AND measure_Id__r.Active__c = true
    		 ORDER BY Calc_DT__c DESC LIMIT 1];
    	
    	if(results4.size()>0){
    		potentialEarnedScore = new Score(Integer.valueOf(results4.get(0).Score__c), results4.get(0).Calc_DT__c);
    	}
    	else{
    		potentialEarnedScore = new Score();
    	}
    	potentialEarnedScore = new Score();
    	
    	List<Expected_Score__c> results3 = 
    		[SELECT Score__c, Calc_DT__c
    		 FROM Expected_Score__c
    		 WHERE contact_ID__c = :c.id AND measure_Id__r.Active__c = true
    		 ORDER BY Calc_DT__c DESC LIMIT 1];
    	
    	if(results3.size()>0){
    		potentialContributedScore = new Score(Integer.valueOf(results3.get(0).Score__c), Date.valueOf(results3.get(0).get('Calc_DT__c')));//results3.get(0).Calc_DT__c);
    	}
    	else{
    		potentialContributedScore = new Score();
    	}
    }
}