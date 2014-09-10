/**
     * A measure is composed of one or more rules.
     * They are stored temporarily in this class as the xml is being parsed
     * Each measure has a list of rules. 
     * 
    **/
  public with sharing class X360Measure {
  	  	public ID measureId { get; set; } // salesforce id for this rule
        public string measureType { get; set; } // soql to be executed    
        public List<X360Rule> rules { get; set; }  //rules
        public string measureName {get; set;}         
        
        public X360Measure(ID measureId, string measureType, string measureName) {
        	this.measureId = measureId;
        	this.measureType = measureType;
        	this.measureName = measureName;
        	rules = new List<X360Rule>();        	
        }

}