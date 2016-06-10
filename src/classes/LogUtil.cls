/**
 * LogUtil class for advanced debugging.
 * This class configuration can be extended in in custom setting DiaLogConfig__c.
 * 
 * Usage: 
 * - initialization
 *      LogUtil log = new LogUtil();                for default error config
 *      
 *      OR
 *
 *      LogUtil log = new LogUtil('custom_mode');   for custom error config
 *      ** replace custom_mode with custom setting name
 *
 *  - execution with various logLevels
 *      log.info(String name, Exception e, String addInfos)
 *      log.warn(String name, Exception e, String addInfos)
 *      log.error(String name, Exception e, String addInfos)
 *      
 *
 * @version     2016-06-08  kevin.kolditz@die-interaktiven.de      first version
 *              
 */

public class LogUtil {
    
    public static sObject error {get;set;}
    
    public static DiaLogConfig__c configMode {get;set;}
    
    public static Map<String, DiaLogConfig__c> configMap;
    
    public LogUtil(){

        configMap = DiaLogConfig__c.getAll();
        System.debug('Default' + configMap.get('Default'));
        configMode = configMap.get('Default');
        error = Schema.getGlobalDescribe().get(configMap.get('Default').Log_Object_Name__c ).newSObject();
    }
    
    public LogUtil(String mode){

        configMap = DiaLogConfig__c.getAll();
        
        if (configMap.get(mode) == null)
        {
            mode = 'Default';   
            System.debug('Error Mode ' + mode + ' not available. Using default diasyslog config.'); 
        }
            
        configMode = configMap.get(mode);
        error = Schema.getGlobalDescribe().get(configMap.get(mode).Log_Object_Name__c ).newSObject();               
            
    }
    

    public Boolean info(String name, Exception e, String addInfos) {
        error.put(configMode.Severity_API_Field__c, 'INFO');
        debugFactory('info',name, e, addInfos);
        return true;
    }
    
    public Boolean warn(String name, Exception e, String addInfos) {
        error.put(configMode.Severity_API_Field__c, 'WARN');

        debugFactory('warn',name, e, addInfos);
        return true;
    }
    
    public Boolean error(String name, Exception e, String addInfos) {
        error.put(configMode.Severity_API_Field__c, 'ERROR');

        debugFactory('error',name, e, addInfos);
        return true;
    }
    
    private static void debugFactory(String logLevel, String name, Exception e, String addInfos) {
    
        if (configMode.Email_Notification__c.contains(logLevel)) {
            
            sendEmailToAdmin(e);
        }
        if (configMode.sObject_Logging__c.contains(logLevel)) {
            
            createErrorLogEntry(name, e, addInfos);
        }
        if (configMode.System_Debug__c.contains(logLevel)) {
            
            System.debug(e);
        }
                
    }
        
    private static sObject createErrorLogEntry(String name, Exception e, String addInfos) {
        
        // set name and cut if too long
        String newName = name + ' - ' + String.valueOf(DateTime.now());
        if (newName.length() <= 80) {

            error.put('Name',newName);
        } else {
            error.put('Name',newName.subString(0, 80));
        }
        
        // set type and cut if too long
        if (e.getTypeName().length() <= 255) {

            error.put(configMode.Type_API_Field__c,e.getTypeName());
        } else {
            error.put(configMode.Type_API_Field__c,e.getTypeName().subString(0, 255));
        }
        
        // set line number
        error.put(configMode.Line_Number_API_Field__c, e.getLineNumber());
        
        // set message and cut if too long
        if (e.getMessage().length() <= 32768) {

            error.put(configMode.Message_API_Field__c, e.getMessage());
        } else {
            error.put(configMode.Message_API_Field__c, e.getMessage().subString(0, 255));
        }
        
        // set stack trace and cut if too long
        if (e.getStackTraceString().length() <= 32768) {

            error.put(configMode.Stack_Trace_API_Field__c, e.getStackTraceString());
        } else {
            error.put(configMode.Stack_Trace_API_Field__c, e.getStackTraceString().subString(0, 255));
        }
        
        // set additional information and cut if too long
        if (addInfos != null) {
            if (addInfos.length() <= 32768) {

                error.put(configMode.Additional_Information_API_Field__c,addInfos);
            } else {
                error.put(configMode.Additional_Information_API_Field__c, addInfos.subString(0, 32768));
            }
        }
        
        insert error.clone();

        return error;
    }
    
    private static void sendEmailToAdmin (Exception e) {
        
        List<String> devMailAddressList = new List<String>();
                
        devMailAddressList = configMode.Admin_Email_Addresses__c.toLowerCase().replace(' ', '').split(',',10);
                
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {};

        for (String d : devMailAddressList) {
            toAddresses.add(d);
        }
        
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('DiaSysLog message');
        mail.setSubject('Log from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(e.getMessage());

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }    

    public static void initialSetup () {

        DiaLogConfig__c testDefaultConf = new DiaLogConfig__c(
        
            sObject_Logging__c                  = 'warn, error', 
            Type_API_Field__c                   = 'Type__c', 
            System_Debug__c                     = 'info, warn,error', 
            Stack_Trace_API_Field__c            = 'Stack_Trace__c', 
            Name                                = 'Default', 
            Message_API_Field__c                = 'Message__c', 
            Severity_API_Field__c               = 'Severity__c', 
            Line_Number_API_Field__c            = 'Line_Number__c', 
            Log_Object_Name__c                  = 'DiaSysLog__c', 
            Email_Notification__c               = 'info, warn, error',
            Admin_Email_Addresses__c            = 'kevin.kolditz@gmail.com, kevin.kolditz@die-interaktiven.de', 
            Additional_Information_API_Field__c = 'Additional_Information__c'
        );

        insert testDefaultConf;
    }

}