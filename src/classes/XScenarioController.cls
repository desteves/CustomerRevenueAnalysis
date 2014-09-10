public class XScenarioController {
	
	public SelectOption[] scenarios {get; set;}
	public string selectedScenario {get; set;}
	public string scenarioName {get; set;}
    public string groupName {get; set;}
    public List<Member> members {get; set;}
    public string contactName {get; set;}
	public List<Scenario_Score__c> scoreDetails {get; set;}
	
	public SelectOption[] measures {get; set;}
	public string selectedMeasure {get; set;}
	
	public SelectOption[] groupLists {get; set;}
	public string selectedList {get; set;}
	
	
	public String executeOutput {get; set;}
	
	public string debug {get; set;}
	public boolean newScenarioSelected {get; set;}
	public boolean newGroupSelected {get; set;} 
	public boolean readyToExec {get; set;} 
	public boolean displayScores {get; set;}
	
	private final string NEW_SCENARIO ='Create new Scenario..';
	private final string NEW_MEASURE = 'Create new Measure..';
	private final string NEW_GROUP = 'Create new group..';
	
	private boolean debuggingMode = true;
	
	public XScenarioController(){
		init();
	}
	/*
	Initialize the page and the variables used in it 
	*/
	private void init(){
		scenarios = new SelectOption[]{new Selectoption(NEW_SCENARIO,NEW_SCENARIO)};
		for(Scenario__c s : getAllScenarios())
		{
			scenarios.add(new SelectOption(s.ID, s.Name));
		}
		newScenarioSelected= false;
		newGroupSelected = false;
		readyToExec = false;
		displayScores = false;
		measures = new SelectOption[]{new SelectOption(NEW_MEASURE, NEW_MEASURE)};
		groupLists = new SelectOption[]{new SelectOption(NEW_GROUP, NEW_GROUP)};
		members = new List<Member>();
        groupName='';
        scoreDetails = new List<Scenario_Score__c>();
        
		List<Contacts_Group__c> definedGroups = 
				[SELECT Name, ID 
				FROM Contacts_Group__c  
				ORDER BY Name];
		for(Contacts_Group__c g : definedGroups){
			groupLists.add(new SelectOption(g.get('ID')+'', g.get('Name')+''));
		}
	}
	
	/*
	A handler for page action:
	Based on the selections in the drop down (Scenario, Contact group, Measure):
	1- display a page block to create new scenario
	2- display a page block to create new Contact group
	3- redirect to measure builder
	4- display the scores for the selected combination Scenario, Contact group 
	   and Measure
	*/
	public PageReference go(){
		PageReference pg =null;
		newScenarioSelected = false;
		newGroupSelected = false;
		displayScores = false;
		scoreDetails.clear();
		if(selectedScenario.equals(NEW_SCENARIO)){
			newScenarioSelected = true;
		}
		else if(selectedList.equals(NEW_GROUP)){
			newGroupSelected = true;
		}
		else if(selectedMeasure.equals(NEW_MEASURE)){
			pg = goToPage(Page.X360Builder, new String[]{selectedScenario, selectedList});
		}
		else{// everything is selected, display the scores
			displayCalculatedScores();
			displayScores = true;
		}
		isReadyToExec();
		
		return pg;
	}
	
	/*
	A handler for page action:
	Saves the selected measure from a scenario to into the measures that will be scehduled
	*/
	public void promote(){
		try{
			Scenario_Measure__c newMeasure = 
				[SELECT Name, Description__c, Definition__c
				 FROM Scenario_Measure__c
				 WHERE Id = :selectedMeasure];
			Measure__c measure = new Measure__c();
	    	   	
	    	measure.Name = newMeasure.Name;
	    	measure.Description__c = newMeasure.Description__c;
	    	measure.Definition__c= newMeasure.Definition__c;
	    	insert measure;
	    	writeMessage('The Measure "' + newMeasure.Name +'" is ready for scheduling');
		}
		catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                writeMessage(e.getDmlMessage(i)); 
            }
        }
        catch(Exception e){
            writeMessage('The measure is not saved');
        }
	}
	
	/*
	retrive the scores for the selected Scenario, Contact group and Measure.
	note: measure and contact group is enough to find the scores for the selections
	*/
	private void displayCalculatedScores(){
		scoreDetails = [SELECT Contact_Id__r.Name, Rule_ID__r.Name, Score__c, Calculation_Date__c 
						FROM Scenario_Score__c
						WHERE Scenario_Measure__r.Id = :selectedMeasure
						AND Scenario_Measure__r.Group_ID__r.Id = :selectedList
						ORDER BY Calculation_Date__c DESC];
	}
	
	/*
	A handler for page action:
	redirect the user to the measure executor and passes the required params.
	*/
	public void execute(){
		
		X360Executor exec = new X360Executor(selectedMeasure, selectedList);
		executeOutput = exec.execute();
		
		if(!executeOutput.contains('Error')){
			go();
			writeMessage('The measure was executed successfully.');
		}
		else {
			writeMessage('The measure was not fully executed.\nPlease contact your administrator');
		}
	}
	
	/*
	A handler for page action:
	parse the params to create and save new scenario.
	*/
	public void create(){
		Scenario__c newScenario = new Scenario__c(Name= scenarioName);
		try{
			insert newScenario;
			writeMessage(scenarioName + ' has been saved successfully');
			//goToPage(Page.XRuleBuilder, newScenario.ID);
			newScenarioSelected = false;
			init();
		}
		catch(Exception e){
			writeMessage('The scenario cannot be saved');
		}
		
	}
	
	/*
	retrieve all the scenarios defined.
	*/
	private List<Scenario__c> getAllScenarios(){
		List<Scenario__c> savedScenarios = [SELECT Name, ID FROM Scenario__c ];
		return savedScenarios;
		
	}
	
	/*
	A handler for page action:
	display the measures associated with the selected scenario.
	*/
	public void scenarios_SelectedIndexChanged(){
		if(!selectedScenario.equals(NEW_SCENARIO)){
			populateMeasures();
		}
		isReadyToExec();
	}
	
	/*
	retrieve the measures associated with the selected scenario and contact group.
	*/
	private void populateMeasures(){
		measures.clear();
		measures.add(new SelectOption(NEW_MEASURE, NEW_MEASURE));
		List<Scenario_Measure__c> definedMeasure = 
		[SELECT Description__c, ID
		FROM Scenario_Measure__c WHERE scenario_ID__r.ID = :selectedScenario];
		for(Scenario_Measure__c m : definedMeasure){
			measures.add(new SelectOption(m.ID, m.Description__c));
		}
	}
	
	/*
	A handler for page action:
	enables/disables the execute button based on the selections from the dropdown.
	*/
	public void isReadyToExec(){
		if(!selectedScenario.equals(NEW_SCENARIO) && !selectedList.equals(NEW_GROUP) && !selectedMeasure.equals(NEW_MEASURE))
			readyToExec = true;
		else
			readyToExec = false;
	}
	
	/*
	redirect the page to the given page reference. If the string param is not empty, 
	it will be passed as id in the URL.
	*/
	private PageReference goToPage(PageReference pg, string[] ids){
		if(ids != null && ids.size() > 1){
				pg.getParameters().put('scenarioid', ids[0]);
				pg.getParameters().put('groupid', ids[1]);
		} 
		pg.setRedirect(true);
		writeDebug(pg.getUrl());
		
		return pg;
	}
	
	/*
	A handler for page action:
	add a selected contact to the group before it is saved.
	*/
	public void addContact(){
        try{
	        Contact con = [SELECT Name FROM Contact WHERE ID=:contactName ];
	        Member m = new Member(con.Name, con.Id);
	        members.add(m);
        }
        catch(System.QueryException e){
        	writeMessage('please enter a vaild name');
        }
    }
    
    /*
	A handler for page action:
	remove a selected contact from the group before it is saved.
	*/
    public void remove(){
        integer id=0;
        for(Member m : members){
            if(m.Id == contactName)
                break;
            id++;
        }
        members.remove(id);
        contactName='';
    }
    
    /*
	A handler for page action:
	save the group with its selected contacts.
	*/
    public void save(){
        try{
	        Contacts_Group__c newGroup = new Contacts_Group__c( Name = groupName);
	        insert newGroup;
	        
	        List<Group_Member__c> newListItems = new List<Group_Member__c>();
	        
	        for(Member m : members){
	            Group_Member__c temp = new Group_Member__c(Group_Id__c=newGroup.Id, Contact_ID__c= m.Id );
	            newListItems.add(temp);
	        }
        
            insert newListItems;
            writeMessage(groupName + ' has been saved successfully');
            init();
        }
        catch(Exception e){
            writeMessage('The group cannot be saved');
        }
    }
    
    /*
	helper function to display the passed messages on the page. 
	*/
	private void writeMessage(string msg){
		debug = msg;
	}
	
	/*
	helper function to display the passed messages. If the debuggingMode is set to false,
	nothing will be displayed.
	*/
	private void writeDebug(string msg){
		if(debuggingMode)
			debug = msg;
	}
	/*
	Helper class to pass and retrieve the group members.
	*/
	public class Member{
        public string Name{get; set;}
        public string Id{get; set;}
        public Member(string name, string id){
            this.Name = name;
            this.Id = id;
        }
    }
}