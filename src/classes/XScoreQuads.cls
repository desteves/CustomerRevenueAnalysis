public class XScoreQuads {
	public class Score{
    	public Integer Score {get; set;}
    	public Datetime CalcDate {get; set;}
    	
    	public Score(Integer score, Datetime calcDate){
    		this.Score = score;
    		this.CalcDate = calcDate;
    	}
    	public Score(){
    		this.Score = 0;
    	}
    }
    
	//added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    // the actual contact
    private Contact c;
    
    // the possible scores for this contact
    public List<Score> historicalScores {get;set;}
    public List<Score> potentialScores {get;set;}
    public List<String> titles {get;set;}
    
    public Score historicalEarnedScore {get;set;}
    public Score historicalContributedScore {get;set;}
    public Score potentialEarnedScore {get;set;}
    public Score potentialContributedScore {get;set;}
    
    public string tier {get;set;}
    public string color {get;set;}
    public string textColor {get;set;}
    
    public XScoreQuads(ApexPages.StandardController controller) {
        //initialize the stanrdard controller
        this.controller = controller;
        this.c = (Contact)controller.getRecord();
        c = [SELECT id, Tier_Id__r.Name__c FROM Contact WHERE ID = :c.Id];
        init();
    }
    
    private void init(){
    	titles = new List<String>{'Contributed', 'Earned'};
    	historicalScores = new List<Score>();
    	potentialScores = new List<Score>();
    	getTier();
    	getScores();
    }
    
    private void getTier(){
    	if(c.Tier_Id__c != null){
    		tier = c.Tier_Id__r.Name__c;
    		textColor = 'black;';

			if(tier.equals('Gold'))
				color = 'gold';
			else if(tier.equals('Silver'))
				color = 'silver';
			else if(tier.equals('Bronze')){
				color = '#665D1E;';
				textColor = 'white;';
			}
			else
				color = 'white;';//'FFFFFF';
    	}
    }
    
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
    	historicalScores.add(historicalContributedScore);
    	
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
    	historicalScores.add(historicalEarnedScore);
    	    	
    	
    	/*
    	List<[NEW_OBJ]> results4 = 
    		[SELECT Score__c, Calc_DT__c 
    		 FROM [NEW_OBJ]
    		 WHERE contact_ID__c = :c.id AND measure_Id__r.Active__c = true
    		 ORDER BY Calc_DT__c DESC LIMIT 1];
    	
    	if(results4.size()>0){
    		potentialContributedScore = new Score(Integer.valueOf(results4.get(0).Score__c), results4.get(0).Calc_DT__c);
    	}
    	else{
    		potentialContributedScore = new Score();
    	}
    	*/
    	potentialContributedScore = new Score();
    	potentialScores.add(potentialContributedScore);
    	
    	List<Expected_Score__c> results3 = 
    		[SELECT Score__c, Calc_DT__c
    		 FROM Expected_Score__c
    		 WHERE contact_ID__c = :c.id AND measure_Id__r.Active__c = true
    		 ORDER BY Calc_DT__c DESC LIMIT 1];
    	
    	if(results3.size()>0){
    		potentialEarnedScore = new Score(Integer.valueOf(results3.get(0).Score__c), results3.get(0).Calc_DT__c);
    	}
    	else{
    		potentialEarnedScore = new Score();
    	}
    	potentialScores.add(potentialEarnedScore);
    }
}