/**
 *
 *  Sends an email.
 *
**/
public with sharing class X360ScheduleEmail {

	private string email {get; set;}    
	private string sender {get; set;}    
	private string subject {get; set;}    
	private string body {get; set;}    
		
	public X360ScheduleEmail(string email, string sender, string subject, string body)
	{
		this.email = email;
		this.sender = sender;
		this.subject = subject;
		this.body = body;
	}
	
	
	public void appendBody(string body)
	{
		this.body += body;
	}
	
	/**
    *
    *  After the job gets completed, the creator of the job will receive an email notification
    *  with details on the results.    	 
    *
    *  https://developer.salesforce.com/forums?id=906F0000000904sIAA
    * 
    **/
	 public boolean SendNotification() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();	 
        String[] toAddresses = new String[] {email};
        // Assign the addresses for the To
        mail.setToAddresses(toAddresses);
        // Specify the name used as the display name. 
        mail.setSenderDisplayName(sender); 
        // Specify the subject line for your email. 
        mail.setSubject(subject); 
        mail.setPlainTextBody(body); 
	    // Send the email you have created. 		
		List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { mail });
		if (!results.get(0).isSuccess()) {
		    //System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
		    //String errorMessage = results.get(0).getErrors()[0].getMessage();
		    system.debug(results.get(0).getErrors()[0].getMessage());
		}
		return results.get(0).isSuccess();
   }
}