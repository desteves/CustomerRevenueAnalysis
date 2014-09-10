public class XContactGroupController {
    
    public string debug {get; set;}
    public string groupName {get; set;}
    public string contactName {get; set;}
    public List<Member> members {get; set;}
    
    private boolean debuggingMode = true;
    
    public XContactGroupController(){
        init();
    }
    private void init(){
        members = new List<Member>();
        groupName='';
    }
    private void writeDebug(string msg){
        if(debuggingMode)
            debug = debug+'\r\n'+msg;
    }
    public void addContact(){
        Contact con = [SELECT Name FROM Contact WHERE ID=:contactName ];
        Member m = new Member(con.Name, con.Id);
        members.add(m);
    }
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
    public void save(){
        List<Contact_Group__c> newListItems = new List<Contact_Group__c>();
        
        for(Member m : members){
            Contact_Group__c temp = new Contact_Group__c(Name=groupName, Contact_ID__c= m.Id );
            newListItems.add(temp);
        }
        try{
            insert newListItems;
            writeDebug(groupName + ' has been saved successfully');
            init();
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                writeDebug(e.getDmlMessage(i)); 
            }
        }
        catch(Exception e){
            writeDebug('The scenario cannot be saved');
        }
    }
    public class Member{
        public string Name{get; set;}
        public string Id{get; set;}
        public Member(string name, string id){
            this.Name = name;
            this.Id = id;
        }
    }
}