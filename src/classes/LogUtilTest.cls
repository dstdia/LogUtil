/**
 * Unit test for LogUtil.
 *
 * @see         LogUtil.cls
 *
 * @version     2016-06-09 kevin.kolditz@die-interaktiven.de      first version
 *              
 */ 

@isTest
private class LogUtilTest {

    public static Account acc;
    static
    {
        LogUtil.initialSetup();
        
        acc = new Account();
    }


    @isTest
    static void debugDefaultTest() {        
        try {
          insert acc;
          System.assert(false);
        }   catch (Exception e) 
        {
            LogUtil inst = new LogUtil();
            
            inst.info('testErrorClass Error', e, 'Error in Account Insert'); 
            inst.warn('testErrorClass Error', e, 'Error in Account Insert'); 
            inst.error('testErrorClass Error', e, 'Error in Account Insert'); 
            System.assert(true);                      
        }
    }
    
    @isTest
    static void debugCustomTest() {       
        try {
          insert acc;
          System.assert(false);
        }   catch (Exception e) 
        {
            LogUtil inst = new LogUtil('Custom_ErrorLog');
            
            inst.info('testErrorClass Error', e, 'Error in Account Insert'); 
            inst.warn('testErrorClass Error', e, 'Error in Account Insert'); 
            inst.error('testErrorClass Error', e, 'Error in Account Insert'); 
            System.assert(true);                     
        }
    }
    
    @isTest
    static void debugFalseModeTest() {       
        try {
          insert acc;
          System.assert(false);
        }   catch (Exception e) 
        {
            LogUtil inst = new LogUtil('NotAvailable_ErrorLog');
            
            inst.info('testErrorClass Error', e, 'Error in Account Insert'); 
            inst.warn('testErrorClass Error', e, 'Error in Account Insert'); 
            inst.error('testErrorClass Error', e, 'Error in Account Insert'); 
            System.assert(true);           
        }
    }
    
    @isTest
    static void toLongMsgTest() {
        String toLongString;
        
        for (Integer i = 0; i<70000; i++)
        {
            toLongString += 'a';
        }
                
        try {
          insert acc;
          System.assert(false);
        }   catch (Exception e) 
        {
            LogUtil inst = new LogUtil('NotAvailable_ErrorLog');
            e.setMessage(toLongString);
            
            inst.info('testErrorClass Error testErrorClass Error testErrorClass Error testErrorClass Error', e, 'Error in Account Insert'); 
            inst.warn('testErrorClass Error testErrorClass Error testErrorClass Error testErrorClass Error', e, 'Error in Account Insert'); 
            inst.error(toLongString, e,toLongString); 
            System.assert(true);           
        }
    }
}