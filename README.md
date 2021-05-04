# MDTriggerManager
Yet another trigger manager...

The difference is, this class makes use of a single custom metadata type (MD_Trigger_Handler__mdt) to allow for adding/removing handlers and enabling/disabling trigger events per object and on an org-wide level.

There is also recursion blocking built in based on record hash codes...

This CMT allows for creating master records, either to control all triggers in the system (Is Master Setting = true and Object = null)
or per-object (Is Master Setting = true and Object != null). Trigger operations can be turned on/off with the event name checkboxes 
(e.g. After Insert).

The names of the CMT records must match the name of the handler class. The ONLY thing that needs to be in each trigger is the following line:

new MDTriggerManager().run();

The trigger should also fire on ALL events. Here is a 100% complete example Account trigger:

    trigger DAccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        new MDTriggerManager().run();
    }

...Never again will you need to deploy trigger updates...unless of course it's to update the API version!

To make a handler, simply extend the MDTriggerManager.Handler class:

    public class MDAccountTriggerHandler extends MDTriggerManager.Handler {

        // for each trigger event you want to handle, include an override for the method in the handler class:
        public override void beforeInsert() {
            // do something on before insert
        }
        
        // you technically don't need to override all of the methods in the MDTriggerManager.Handler class...only those you need
        public override void afterInsert() {
            // and something after insert
        }

        public override void beforeUpdate() {
            // maybe a little something before that update!
        }
    }

This repo comes with a few examples of MD_Trigger_Handler__mdt records as well as an example trigger DAccountTrigger and an example class: MDAccountTriggerHandler
