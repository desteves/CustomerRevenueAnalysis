public class XScoreDetails {
	
	public string measureDesc{get; set;}
	public string dateStr{get; set;}
	public  List <ScoreDetail> scoreDetails{get;set;}
	
	
	public XScoreDetails(){
		
		string scoreType =  ApexPages.currentPage().getParameters().get('sc');
		string table ='';
		
		if(scoreType.equals('Ex')) table = 'Expected_Score__c';
		else if(scoreType.equals('E')) table = 'Earned_Score__c';
		else if(scoreType.equals('Exa')) table = 'Account_Expected_Score__c';
		else if(scoreType.equals('Ea')) table = 'Account_Earned_Score__c';
		else if(scoreType.equals('c')) table = 'Contributed_Score__c';
		else return;
		
		dateStr = ApexPages.currentPage().getParameters().get('date');
		
		Boolean isAccount =false;
		String entityId= ApexPages.currentPage().getParameters().get('cid');
		if(isAccount = entityId==null) entityId= ApexPages.currentPage().getParameters().get('aid');
		loadMeasureDescForContact(
			entityId,
			dateStr, table,isAccount );
			
	}
	private void loadMeasureDescForContact(string contactId, string dateVal, string table, Boolean isAccount ){
		scoreDetails = new List<ScoreDetail>();
		
		Date d = Date.valueOf(dateStr);
		
		if(d== null) return;
		
		String month= d.month()+'';// dateStr.split('/')[0];
		if(d.month() < 10 )
			month = '0' + month;
			
		string day= d.day()+'';//dateStr.split('/')[1];
		if(d.day() < 10)
			day = '0' + day;
		
		string year = d.year()+'';
		
		dateStr = year + '-' + month +'-'+day;//dateStr.split('/')[2]+'-'+ month +'-'+day;
		String idStr = ' AND Contact_id__r.id = \'';
		if(isAccount) idStr = ' AND Account__r.id = \'';
		
		String q = 'SELECT Measure_id__r.Description__c, Measure_id__r.ID FROM '+table+
		' WHERE Day_ONLY(Calc_DT__c) = '+ dateStr
		 + idStr + contactId +'\' ORDER BY Calc_DT__c DESC LIMIT 1';
		 
		List<SObject> results = Database.query(q);
		SObject measure = results[0].getSObject('Measure_id__r');
		this.measureDesc = (String)measure.get('Description__c')+ ' measureID:' +(String)measure.get('ID'); 
		
		q = 'SELECT rule__r.id, rule__r.Description__c ,rule__r.Name__c , score__c FROM '+table+
		' WHERE Day_ONLY(Calc_DT__c) = '+ dateStr
		 + idStr + contactId +'\' AND Measure_Id__r.ID = \''+(String)measure.get('ID')+
		 '\' ORDER BY Calc_DT__c DESC';
		
		//this.measureDesc = (String) result[0].Measure_Id__c;
		results = Database.query(q);
		//[SELECT rule__r.id, rule__r.Description__c ,rule__r.Name__c , score__c 
		//FROM Contributed_Score__c
		//WHERE Day_ONLY(Calc_DT__c) = :dateVal AND Contact_id__r.id = :contactId];
		
		for(SObject r: results)
		{
			SObject a = r.getSObject('rule__r'); 
			scoreDetails.add(new ScoreDetail((String)r.get('id'), (String)a.get('Name__c'),
			 (String)a.get('Description__c'), Double.valueOf(r.get('score__c'))));
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