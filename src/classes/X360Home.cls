public class X360Home {
	public  list <top> topExpectedList{get;set;}
	public  list <top> topEarnedList{get;set;}
	public  list <top> topContributedList{get;set;}
	public  list <top> topExpectedAccountList{get;set;}
	public  list <top> topEarnedAccountList{get;set;}
public class top{
   public string Name {get;set;}
   public double Score {get;set;}
   public string Id {get;set;}
   public Date DateVal {get;set;}
   public top( string id, string name, double score, Date dateVal){
      this.Id = id;
      this.Name = name;
      this.Score = score;
      this.DateVal = dateVal;
   }
}

	public X360Home() {
		getTop();
	}
	public void getTop(){
		topExpectedList = new List<top>();
		topEarnedList = new List<top>();
		topContributedList = new List<top>();
		topEarnedAccountList = new List<top>();
		topExpectedAccountList = new List<top>();
		
		Integer iAge = 18;
		try{			
			iAge = [SELECT AgeRestriction__c FROM X360__c WHERE AgeRestriction__c != NULL limit 1].AgeRestriction__c.intValue();
		} catch (Exception e)
		{
			//not available
		}
		Date d = System.today() - iAge*365;
		
	 for(AggregateResult o:[SELECT Contact_Id__r.Id, Contact_Id__r.Name name, MAX(Calc_DT__c) date, SUM(Score__c) score
							FROM Expected_Score__c
							WHERE Contact_Id__r.dob__c < :d OR Contact_Id__r.dob__c = NULL							
							GROUP BY Contact_Id__r.Id, Contact_Id__r.Name, DAY_ONLY(Calc_DT__c)
							ORDER BY DAY_ONLY(Calc_DT__c) DESC, SUM(Score__c) DESC limit 10])
		{
			topExpectedList.add(new top((String)o.get('id'),
			 (String)o.get('name'),
			 Double.valueOf(o.get('score')), Date.valueOf(o.get('date'))));
		}
		Set<String> ids = new Set<String>();
		for(AggregateResult o:[SELECT Contact_Id__r.Id, Contact_Id__r.Name name, MAX(Calc_DT__c) date, SUM(Score__c) score
							FROM Earned_Score__c
							WHERE Contact_Id__r.dob__c < :d OR Contact_Id__r.dob__c = NULL
							GROUP BY Contact_Id__r.Id, Contact_Id__r.Name, DAY_ONLY(Calc_DT__c)
							ORDER BY DAY_ONLY(Calc_DT__c) DESC, SUM(Score__c) DESC
							limit 10])
		{
			if(!ids.contains((String)o.get('id'))){
				ids.add((String)o.get('id'));
				topEarnedList.add(new top((String)o.get('id'), (String)o.get('name'), Double.valueOf(o.get('score')), Date.valueOf(o.get('date'))));
			}
		}
		for(AggregateResult o:[SELECT Contact_Id__r.Id, Contact_Id__r.Name name, MAX(Calc_DT__c) date, SUM(Score__c) score
							FROM Contributed_Score__c
							WHERE Contact_Id__r.dob__c < :d OR Contact_Id__r.dob__c = NULL
							GROUP BY Contact_Id__r.Id, Contact_Id__r.Name, DAY_ONLY(Calc_DT__c)
							ORDER BY DAY_ONLY(Calc_DT__c) DESC, SUM(Score__c) DESC
							limit 10])
		{
			topContributedList.add(new top((String)o.get('id'),(String)o.get('name'), Double.valueOf(o.get('score')),
			 Date.valueOf(o.get('date'))));
		}
		for(AggregateResult o:[SELECT Account__r.Id, Account__r.Name name,  MAX(Calc_DT__c) date, SUM(Score__c) score
							FROM Account_Earned_Score__c
							GROUP BY Account__r.Id, Account__r.Name, DAY_ONLY(Calc_DT__c)
							ORDER BY DAY_ONLY(Calc_DT__c) DESC, SUM(Score__c) DESC
							limit 10])
		{
			topEarnedAccountList.add(new top((String)o.get('id'),(String)o.get('name'), Double.valueOf(o.get('score')),
			 Date.valueOf(o.get('date'))));
		}
		for(AggregateResult o:[SELECT Account__r.Id, Account__r.Name name,  MAX(Calc_DT__c) date, SUM(Score__c) score
							FROM Account_Expected_Score__c
							GROUP BY Account__r.Id, Account__r.Name, DAY_ONLY(Calc_DT__c)
							ORDER BY DAY_ONLY(Calc_DT__c) DESC, SUM(Score__c) DESC
							limit 10])
		{
			topExpectedAccountList.add(new top((String)o.get('id'),(String)o.get('name'), Double.valueOf(o.get('score')),
			 Date.valueOf(o.get('date'))));
		}
	}

}