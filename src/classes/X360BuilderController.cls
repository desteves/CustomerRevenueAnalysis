//COntroller for measure builder 
public  class X360BuilderController {

public List<Rule__c> Rules {get;set;}

public List<X360RuleUI> rulesUI {get;set;}

public String measureDef {get;set;}

public String ScenarioId {get;set;}
public String GroupId {get;set;}

public List<Measure_Type__c> MeasureTypes {get;set;}

public X360BuilderController() {
        
        //get scenario ID
        //try
        //{
        PageReference pageRef = ApexPages.currentPage();
        ScenarioId = pageRef.getParameters().get('scenarioid');
        GroupId = pageRef.getParameters().get('groupid');
        
        List<Measure_Type__c> MeasureTypes = [Select Name,Measure_Type_Code__c from Measure_Type__c];
        
        
        measureDef = '';
        
        Rules = [Select Id,Definition__c,Description__c,Name,Type__c from Rule__c ];
        
        rulesUI = new List<X360RuleUI>();
        
        //get list of rules for displaying in the UI.
        for(Rule__c rul : Rules)
        {
        
            X360RuleUI ui = new X360RuleUI();
            
            
            ui.Rule =rul;
            
            List<X360RuleParameter> params= new List<X360RuleParameter>(); 
    
            String XML = rul.Definition__c;
        
            Dom.Document doc = new Dom.Document();
        
            doc.load(XML);
        
        
            Dom.XMLNode xRule = doc.getRootElement();
            
            Dom.XMLNode xParams = xRule.getChildElement('Params', null);
            
            X360RuleParameter param;
            
            if(xParams!=null)
            {
            for(Dom.Xmlnode xParam : xParams.getChildElements() )
            {
                    string id = xParam.getAttribute('id',null);
                    string sType = xParam.getAttribute('Datatype',null);                            
                    string sName = xParam.getAttribute('Name',null);
                    string isMultiple = xParam.getAttribute('multiple',null);
                    
                    Dom.XmlNode xValues = xParam.getChildElement('Values', null);
                    
                    List<string> values = new List<string>();
                    
                    if(xValues!=null)
                    {
                        for(Dom.Xmlnode xVal : xValues.getChildElements())
                        {
                            values.add(xVal.getText());
                        }
                    }
                    
                            
                    param = new X360RuleParameter(id,sName, sType, null,values,isMultiple);
                    params.add(param);  
            }
            
            ui.params = params;
            }
            rulesUI.add(ui);
        }
        
        
        String Edit= '';
        String EditScenario= '';
        
         Edit = pageRef.getParameters().get('editmeasure');
        
        
         EditScenario = pageRef.getParameters().get('editscenariomeasure');
        
            if(EditScenario!='')
            {
                
                Scenario_Measure__c smeasure = [Select Id,Name,Scenario_ID__c,Description__c,Definition__c,Group_ID__c from Scenario_Measure__c where Id=:EditScenario];
                measureDef = EditScenario;          
            }
            if(Edit!='')
            {
                System.Debug( Edit); 
                Measure__c measure = [Select Id,Name,Description__c,Definition__c from Measure__c where Id=:Edit];              
                measureDef = measure.Id;
            }
            
        
        
    
        
      //  }
        //catch(Exception ex)
        //{
         //   System.Debug( ex.getMessage());    
           //   measureDef = ex.getMessage(); 
        //}
        
        
    }   
    
    
    //temporary classes to read UI values
    
    public class MeasureDefinition
    {
        public String MeasureName;
        public String MeasureDescr;
        public String MeasureType;
        public RulesDef[] RulesDefs = new List<RulesDef>() ;
            
    }
    
    public class RulesDef
    {
        public String id;
        public ParameterDef[] params  = new List<ParameterDef>();   
        
    }
    
    public class ParameterDef
    {
        public String id;
        public String value;
        
        
    }
    
    
    
    public PageReference getSave(){
    {
        
        //Deserialize JSON from Javascript to save
        
        try
        {
        MeasureDefinition mDef= (MeasureDefinition)JSON.deserialize(measureDef, X360BuilderController.MeasureDefinition.class);
        
        
        
        
        

        DOM.Document doc = new DOM.Document();

        dom.XmlNode xMeasure
            = doc.createRootElement('Rules',null,null);
       
       if( mDef.RulesDefs==null)
       System.Debug( 'Null');
       
       
       for(RulesDef rule : mDef.RulesDefs)
        {
            
        
        dom.XmlNode xRule
            = xMeasure.addChildElement('Rule',null,null);
      
        xRule.setAttribute('id', rule.id);
        xRule.setAttribute('score','20');
        
        dom.XmlNode xParams
            = xRule.addChildElement('Params',null,null);
        
                for(ParameterDef para: rule.params)
                {
                     dom.XmlNode xParam
                        = xParams.addChildElement('Param',null,null);
                    xParam.setAttribute('id', para.id);
                    xParam.addTextNode(para.value);
                }
      
        }
        
        if(ScenarioId==null)
        {
            Measure__c measure = new Measure__c();
            System.Debug(mDef.MeasureName + mDef.MeasureDescr);     
            measure.Name = mDef.MeasureName;
            measure.Description__c = mDef.MeasureDescr;
            measure.Definition__c= doc.toXmlString();
            insert measure;
        }
        else
        {
            // If scenario measure
            Scenario_Measure__c measure = new Scenario_Measure__c();        
            measure.Name = mDef.MeasureName;
            measure.Description__c = mDef.MeasureDescr;
            measure.Definition__c= doc.toXmlString();
            measure.Scenario_ID__c = ScenarioId;
            
            measure.Group_ID__c =GroupId;
            insert measure;         
        }
        
            measureDef = 'Measure Saved Successfully';
        }
        catch(Exception ex)
        {
            System.Debug( ex.getMessage());
            
            measureDef = 'Error occurred. Contact administrator';
            
        }
        
        return null;
    }
}
    
}