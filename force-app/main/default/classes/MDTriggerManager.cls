/************************************************

@class		MDTriggerManager

@brief		MDTriggerManager
            Yet another trigger manager

            The difference is, this class only makes use of a single custom metadata type (MD_Trigger_Handler__mdt)

            This CMT allows for creating master records, either to control all triggers in the system (Is Master Setting = true and Object = null)
            or per-object (Is Master Setting = true and Object != null). Trigger operations can be turned on/off with the event name checkboxes 
            (e.g. After Insert).

            The names of the CMT records must match the name of the handler class. The ONLY thing that needs to be in each trigger is the following line:

            new MDTriggerManager().run();

            The trigger should also fire on ALL events. Here is a 100% complete example trigger:

            trigger DAccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
                new MDTriggerManager().run();
            }

            To make a handler, simply extend the MDTriggerManager.Handler class:

            public class MDAccountTriggerHandler extends MDTriggerManager.Handler {
                ...
            }

            For each trigger event you want to handle, include an override for the method in the handler class:

            public override void beforeInsert() {
                // do something on before insert
            }


@author		Brett Wagner

@version	01/08/21 BW - Created
            05/03/21 BW - Converted CMT query to getAll().values()

**************************************************/
public class MDTriggerManager {
    private final String MASTER_SETTING_DEFAULT_NAME = 'MDTriggerManager.defaultSettings';

    public virtual class Handler {
        // overridable methods
        public virtual void beforeInsert() {}
        public virtual void beforeUpdate() {}
        public virtual void beforeDelete() {}
        public virtual void afterInsert() {} 
        public virtual void afterUpdate() {}
        public virtual void afterDelete() {}
        public virtual void afterUndelete() {}
    }

    private static Map<String, Set<String>> eventClassMap = new Map<String, Set<String>>();
    private static Map<String, Boolean> recursionSettings = new Map<String, Boolean>();
    private static Map<String, MD_Trigger_Handler__mdt> masterSettingMap = new Map<String, MD_Trigger_Handler__mdt>();
    private static Map<String, Set<String>> hashMap = new Map<String, Set<String>>();

    private TriggerOperation operation;
    private String objectName;
    private String objectOpp;
    private String hashCode;
    private class No_Settings_Found_Exception extends Exception {}
    private class Invalid_Class_Exception extends Exception {}
    private class Invalid_Class_Name_Exception extends Exception {}

    public MDTriggerManager() {
        this.objectName = (Trigger.isDelete ? Trigger.old : Trigger.new).getSObjectType().getDescribe().getName();
        this.operation = Trigger.operationType;
        this.objectOpp = this.objectName + '.' + this.operation;
        if(MDTriggerManager.eventClassMap.isEmpty()) {
            // cache the trigger handler settings for all handlers
            for(MD_Trigger_Handler__mdt setting : MD_Trigger_Handler__mdt.getAll().values()) {

                if(setting.Is_Master_Setting__c) {
                    MDTriggerManager.masterSettingMap.put(setting.Object__c == null ? MASTER_SETTING_DEFAULT_NAME : setting.Object__c, setting);
                    continue;
                }

                MDTriggerManager.recursionSettings.put(this.objectName + '.' + setting.Label, 
                    this.getMasterSettingValue('Enable_Recursion_Blocker__c', setting.Object__c) && setting.Enable_Recursion_Blocker__c);
                for(TriggerOperation op : TriggerOperation.values()) {
                    String objectOperation = setting.Object__c + '.' + op;
                    if(!MDTriggerManager.eventClassMap.containsKey(objectOperation)) {
                        MDTriggerManager.eventClassMap.put(objectOperation, new Set<String>());
                    }
                    if(this.getMasterSettingValue('Enabled__c', setting.Object__c) && (Boolean)setting.get('Enabled__c')
                            && this.getMasterSettingValue(op + '__c', setting.Object__c) && (Boolean)setting.get(op + '__c')) {
                        MDTriggerManager.eventClassMap.get(objectOperation).add(setting.Label);
                    }
                }
            }
        }
    }

    public void run() {
        Set<String> handlers = MDTriggerManager.eventClassMap.get(this.objectOpp);
        if(handlers == null) {
            // nothing to execute (would throw null error otherwise in the for loop)
            return;
        }

        if(this.getMasterSettingValue('Enable_Recursion_Blocker__c', this.objectName)) {
            this.hashCode = String.valueOf((Trigger.new != null ? Trigger.new : Trigger.old)).replaceAll('(SystemModstamp=.{4,19}, )', '')
                                .replaceAll('(LastModifiedDate=.{4,19}, )', '')
                                .hashCode()
                                + '.' + this.objectOpp;
            System.debug('hashCode: ' + this.hashCode);
            if(!MDTriggerManager.hashMap.containsKey(this.hashCode)) {
                MDTriggerManager.hashMap.put(this.hashCode, new Set<String>());
            }
            // remove handlers that already parsed the records
            handlers.removeAll(MDTriggerManager.hashMap.get(this.hashCode));
        }

        for(String handler : handlers) {
            if(MDTriggerManager.recursionSettings.get(this.objectName + '.' + handler)) {
                MDTriggerManager.hashMap.get(this.hashCode).add(handler);
            }
            Type t = Type.forName(handler);

            if(t == null) {
                throw new Invalid_Class_Name_Exception(handler + ' does not exist. Please double check that the label in the MD Trigger Handler custom metadata record matches the handler class name.');
            }

            if(!MDTriggerManager.Handler.class.isAssignableFrom(t)) {
                throw new Invalid_Class_Exception(handler + ' does not extend the ' + MDTriggerManager.Handler.class.getName() + ' class.');
            }

            Handler theHandler = (Handler)t.newInstance();
            switch on this.operation {
                when AFTER_INSERT {
                    theHandler.afterInsert();
                }
                when AFTER_UPDATE {
                    theHandler.afterUpdate();
                }
                when AFTER_DELETE {
                    theHandler.afterDelete();
                }
                when AFTER_UNDELETE {
                    theHandler.afterUndelete();
                }
                when BEFORE_INSERT {
                    theHandler.beforeInsert();
                }
                when BEFORE_UPDATE {
                    theHandler.beforeUpdate();
                }
                when BEFORE_DELETE {
                    theHandler.beforeDelete();
                }
            }
        }
    }

    private Boolean getMasterSettingValue(String fieldAPI, String objectAPIName) {
        MD_Trigger_Handler__mdt settingMD = MDTriggerManager.masterSettingMap.get(objectAPIName);
        Boolean objectSetting = (Boolean)(settingMD == null ? true : settingMD.get(fieldAPI));
        // the master setting always takes precedence
        MD_Trigger_Handler__mdt masterSettingMD = MDTriggerManager.masterSettingMap.get(MASTER_SETTING_DEFAULT_NAME);
        Boolean masterSetting = (Boolean)(masterSettingMD == null ? true : masterSettingMD.get(fieldAPI));
        return masterSetting && objectSetting;
    }
}