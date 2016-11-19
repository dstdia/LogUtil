/**
 * Scheduling class which deletes debug logs after a certain amount of time automatically. 
 *
 * @see         RecordDeleteBatch.cls
 *
 * @version     2016-06-14 kevin.kolditz@die-interaktiven.de      first version
 * 			    
 */	


global class LogDeleteSched implements Schedulable {

	global void execute(SchedulableContext sc) {

		Map<String, DiaLogConfig__c> configMap = DiaLogConfig__c.getAll();		

		for (String modeString : configMap.keySet()) {

			String sObjectAPIName = configMap.get(modeString).Log_Object_Name__c;

			// only delete logs if there is a value in delete logs field, otherwise do not delete logs for this object
			if(configMap.get(modeString).Number_of_days_to_delete_log__c != null) {

				Integer dayNumber = Integer.valueOf(configMap.get(modeString).Number_of_days_to_delete_log__c);
				String dateTimeFormat = Datetime.now().addDays(dayNumber * (-1)).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
				String whereClause = 'CreatedDate < ' + dateTimeFormat; 

				RecordDeleteBatch batch = new RecordDeleteBatch(	sObjectAPIName,
																	whereClause);
				Database.executeBatch(batch);
			}
		}

	}
}