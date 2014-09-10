public class XScoreDetailsController {
	
	public string measureDesc{get; set;}
	public string dateStr{get; set;}
	public  List <ScoreDetail> scoreDetails{get;set;}
	
	
	public XScoreDetailsController(){
		scoreDetails = new List<ScoreDetail>();
		string scoreType =  ApexPages.currentPage().getParameters().get('sc');
		string table ='';
		
		if(scoreType.equalsIgnoreCase('Ex')) table = 'Expected_Score__c'; //potential contributed
		else if(scoreType.equalsIgnoreCase('E')) table = 'Earned_Score__c'; //historical
		else if(scoreType.equalsIgnoreCase('Exa')) table = 'Account_Expected_Score__c'; //historical
		else if(scoreType.equalsIgnoreCase('ea')) table = 'Account_Earned_Score__c';
		else if(scoreType.equalsIgnoreCase('c')) table = 'Contributed_Score__c';
		else if(scoreType.equalsIgnoreCase('pe')) table = 'Potential_Earned_Score__c';
		else return;
		
		dateStr = ApexPages.currentPage().getParameters().get('date');
		
		Boolean isAccount =false;
		String entityId= ApexPages.currentPage().getParameters().get('cid');
		
		if(isAccount = entityId==null) 
			entityId= ApexPages.currentPage().getParameters().get('aid');
			
		if((dateStr.split('/')).size() > 2)
			loadMeasureDescForContact(
				entityId,
				dateStr, table,isAccount );
			
	}
	private void loadMeasureDescForContact(string contactId, string dateVal, string table, Boolean isAccount ){
		scoreDetails = new List<ScoreDetail>();
		String month= dateStr.split('/')[0];
		if(month.length() < 2 )
			month = '0' + month;
		string day= dateStr.split('/')[1];
		if(day.length() < 2)
			day = '0' + day;
		dateStr = dateStr.split('/')[2]+'-'+ month +'-'+day;
		String idStr = ' AND Contact_id__r.id = \'';
		
		if(isAccount) 
			idStr = ' AND Account__r.id = \'';
		
		String q = 'SELECT Measure_id__r.Description__c FROM '+table+' WHERE Day_ONLY(Calc_DT__c) = '+ dateStr 
		 + idStr + contactId +'\'';
		List<SObject> results = Database.query(q);
		if(results != null && results.size()>0){
			SObject obj = results[0].getSObject('Measure_id__r');
			if(obj != null)
				this.measureDesc = (String)obj.get('Description__c'); 
		}
		q = 'SELECT rule__r.id, rule__r.Description__c ,rule__r.Name , score__c FROM '+table+' WHERE Day_ONLY(Calc_DT__c) = '+ dateStr 
		 + idStr + contactId +'\'';
		
		results = Database.query(q);
		
		for(SObject r: results)
		{
			if(r!=null){
				SObject a = r.getSObject('rule__r');
				if(a != null)
					scoreDetails.add(new ScoreDetail((String)r.get('id'), (String)a.get('Name'),
						 (String)a.get('Description__c'), Double.valueOf(r.get('score__c'))));
				
			}
		}
	}
	public class ScoreDetail{
		public string Name {get;set;}
		public string Description {get;set;}
   		public double Score {get;set;}
   		public string Id {get;set;}
   		
   		public ScoreDetail( string id, string name, string description, double score){
      		this.Id = id;
      		this.Name = name;
      		this.Description = description;
      		this.Score = score;
   		}
	}
}