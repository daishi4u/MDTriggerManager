/************************************************

@class		DAccountTrigger

@brief		DAccountTrigger
            This trigger should be removed.
            This is only an example to help provide test coverage for an initial install.


@author		Brett Wagner 

@version	12/15/20 BW - Created

**************************************************/
trigger DAccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Test.isRunningTest()) {  // only runs when tests are ran to prevent conflicts with existing trigger functionality
        new MDTriggerManager().run();
    }
}