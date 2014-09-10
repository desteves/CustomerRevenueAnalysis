/**
     * A measure is composed of one or more rules.
     * They are stored temporarily in this inner class as the xml is being parsed
     * Each rule has a list of parameters. 
     * 
     * This class is responsible for iterating to the parameters and constructing a rule
     * which will then be executed.
     * 
    **/
public with sharing class X360Rule {
        public String id { get; set; } // salesforce id for this rule
        public string query { get; set; } // soql to be executed
        public string score { get; set; } //number 1-100   
        public string name {get; set;}    
        public string description {get; set; } 
        public list<X360Param> params { get; set; } 
        
        //default constructor
        public X360Rule()
        {
            params = new List<X360Param>();
        }        
        
        public string constructRule()
        {
            string constructedRule = query;         
            //TODO make this more robust, needs to know how to replace the id           
            for(X360Param param: params)
            {     
                constructedRule = constructedRule.replace(param.id, param.value);
            }           
            return constructedRule;                                 
        } 
    }