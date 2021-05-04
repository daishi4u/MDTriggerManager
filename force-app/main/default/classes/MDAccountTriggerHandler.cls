// this is simply an example class
public class MDAccountTriggerHandler extends MDTriggerManager.Handler {
    // method overrides
    // you don't need to override all of them, only the ones you need in your handler

    public override void beforeInsert() {
        // this isn't needed, but is used to provide test coverage
        super.beforeInsert();

        // before insert code here
        System.debug('MDAccountTriggerHandler.beforeInsert: Before Insert overridden!!');
    }

    // demonstrates using filtered records
    public override void beforeUpdate() {
        // this isn't needed, but is used to provide test coverage
        super.beforeUpdate();

        for(Account a : (List<Account>)Trigger.new) {
            if(a.AnnualRevenue == 100001) {
                a.AnnualRevenue = a.AnnualRevenue + 1;
            }
        } 

        // before update code here
        System.debug('MDAccountTriggerHandler.beforeUpdate: Before Update overridden!!');
    }

    public override void beforeDelete() {
        // this isn't needed, but is used to provide test coverage
        super.beforeDelete();

        // before delete code here
        System.debug('MDAccountTriggerHandler.beforeDelete: Before Delete overridden!!');
    }

    public override void afterInsert() {
        // this isn't needed, but is used to provide test coverage
        super.afterInsert();

        // after insert code here
        System.debug('MDAccountTriggerHandler.afterInsert: After Insert overridden!!');
    } 

    public override void afterUpdate() {
        // this isn't needed, but is used to provide test coverage
        super.afterUpdate();

        // after update code here
        System.debug('MDAccountTriggerHandler.afterUpdate: After Update overridden!!');
    }

    public override void afterDelete() {
        // this isn't needed, but is used to provide test coverage
        super.afterDelete();

        // after delete code here
        System.debug('MDAccountTriggerHandler.afterDelete: After Delete overridden!!');
    }

    public override void afterUndelete() {
        // this isn't needed, but is used to provide test coverage
        super.afterUndelete();

        // after undelete code here
        System.debug('MDAccountTriggerHandler.afterUndelete: After Undelete overridden!!');
    }
}