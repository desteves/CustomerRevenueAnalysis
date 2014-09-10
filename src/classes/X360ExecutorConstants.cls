/**
 * classname: X360ExecutorConstants
 * about: Constants to be used by the measure executor
 * 
**/
public with sharing class X360ExecutorConstants {

	public static final String DEFAULT_JOB_NAME = 'X360 Measure Executor';
	public static final String DEFAULT_PARSABLE_MEASURES_SOQL = 'SELECT Id, Name, Definition__c, MeasureType__r.Measure_Type_Code__c From Measure__c WHERE Executable__c = true';
	
	public static final String ACCOUNT_HISTORICAL_EARNED= 'AHC';
	public static final String ACCOUNT_HISTORICAL_EARNED_TABLE = '???';
	
	public static final String ACCOUNT_HISTORICAL_CONTRIBUTED = 'AHE';
	public static final String ACCOUNT_HISTORICAL_CONTRIBUTED_TABLE = 'Account_Earned_Score__c';
	
	public static final String ACCOUNT_POTENTIAL_CONTRIBUTED = 'APC';
	public static final String ACCOUNT_POTENTIAL_CONTRIBUTED_TABLE = 'Account_Expected_Score__c';
	
	public static final String ACCOUNT_POTENTIAL_EARNED = 'APE';
	public static final String ACCOUNT_POTENTIAL_EARNED_TABLE = '???';
	
	public static final String ACCOUNT_TYPES = ACCOUNT_HISTORICAL_EARNED + '|'
											 + ACCOUNT_HISTORICAL_CONTRIBUTED +	'|'
											 + ACCOUNT_POTENTIAL_CONTRIBUTED + '|' 
											 + ACCOUNT_POTENTIAL_EARNED;
	
	public static final String CONTACT_HISTORICAL_EARNED= 'CHC';
	public static final String CONTACT_HISTORICAL_EARNED_TABLE = 'Contributed_Score__c';
	
	public static final String CONTACT_HISTORICAL_CONTRIBUTED = 'CHE';
	public static final String CONTACT_HISTORICAL_CONTRIBUTED_TABLE = 'Earned_Score__c';
	
	public static final String CONTACT_POTENTIAL_CONTRIBUTED = 'CPC';
	public static final String CONTACT_POTENTIAL_CONTRIBUTED_TABLE = 'Expected_Score__c';
	
	public static final String CONTACT_POTENTIAL_EARNED = 'CPE';
	public static final String CONTACT_POTENTIAL_EARNED_TABLE = 'Potential_Earned_Score__c';
	
	public static final String CONTACT_TIER = 'TIR';
	public static final String CONTACT_TIER_TABLE = 'Contact';
	
	public static final String CONTACT_TYPES = CONTACT_HISTORICAL_EARNED + '|'
											 + CONTACT_HISTORICAL_CONTRIBUTED +	'|'
											 + CONTACT_POTENTIAL_CONTRIBUTED + '|' 
											 + CONTACT_POTENTIAL_EARNED  + '|' 
											 + CONTACT_TIER;
		
	public static final String SCENARIO_TABLE = 'Scenario_Score__c';
	
	
}