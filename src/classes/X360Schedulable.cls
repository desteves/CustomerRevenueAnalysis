/**
 * 
 * Salesforce Schedulable class.
 * It contains the Measure Executor. 
 * See @X360Executor
 *
 * 
**/
global class X360Schedulable  implements Schedulable {
	
	/**
	 * 
	 * This method will be executed at a determined Frequency
	 * 
	**/
	 global void execute(SchedulableContext SC) {	 	
      X360Executor x360Executor = new X360Executor(); 
      x360Executor.execute();
   }
}