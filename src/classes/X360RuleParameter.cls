public with sharing class X360RuleParameter {

	public string Id {get;set;}
   public string Name {get;set;}
   public string Type {get;set;}
   public string Value {get;set;}
   public List<string> Values{get;set;}
   public string isMultiple {get;set;}
   
   public X360RuleParameter(string Id,string name, string type, string value, List<String> values, string ismultiple)
   { 
   	this.Id = Id;
   	this.Name = name;
   	this.Type = type;
   	this.value = value;
   	this.values = values;
   	this.isMultiple = ismultiple;
   }
   
}