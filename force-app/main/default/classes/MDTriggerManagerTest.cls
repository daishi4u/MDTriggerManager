@isTest
public class MDTriggerManagerTest {
    private static final Integer NUMBER_OF_TEST_ACCOUNTS = 400;

    private static List<Account> makeAccounts(Boolean shouldInsert) {
        List<Account> accts = new List<Account>();
        for(Integer i = 0; i < NUMBER_OF_TEST_ACCOUNTS; i++) {
            Account a = new Account(Name = 'Test ' + i, BillingState = 'CA');
            a.AnnualRevenue = (Math.mod(i, 2) == 0 ? 100000 : 100001);  // make odds have rev over $100,000
            accts.add(a);
        }
        if(shouldInsert) {
            insert accts;
        }
        return accts;
    }

    @isTest 
    static void testInsert() { 
        System.debug('MDTriggerManagerTest.testInsert()');
        List<Account> accts = makeAccounts(false);
        Test.startTest();
        insert accts;
        Test.stopTest();

        List <Account> updatedAccounts = [SELECT Id FROM Account];
        System.assertEquals(NUMBER_OF_TEST_ACCOUNTS, updatedAccounts.size());
    }

    @isTest
    static void testUpdate() {
        System.debug('MDTriggerManagerTest.testUpdate()');
        List<Account> accts = makeAccounts(true);
        List<Account> updatedAccounts = [SELECT Id, AnnualRevenue FROM Account WHERE AnnualRevenue = 100000];
        System.assertEquals(NUMBER_OF_TEST_ACCOUNTS / 2, updatedAccounts.size());
        
        Test.startTest();
        System.debug('MDTriggerManagerTest.testUpdate() - 1');
        update accts;
        // Test the recursion blocker. Note that Process Builders, Workflows, and flows can update accounts when they are created leading to the testUpdate method failing with
        // the recursion blocker on. if this is the case then comment out BOTH of the update statements and the test will pass.
        System.debug('MDTriggerManagerTest.testUpdate() - 2');
        update accts[0];
        System.debug('MDTriggerManagerTest.testUpdate() - 3');
        update accts[0];
        Test.stopTest();

        updatedAccounts = [SELECT Id, AnnualRevenue FROM Account WHERE AnnualRevenue > 100001];
        System.assertEquals(NUMBER_OF_TEST_ACCOUNTS / 2, updatedAccounts.size());
    }

    @isTest
    static void testDelete() {
        System.debug('MDTriggerManagerTest.testDelete()');
        List<Account> accts = makeAccounts(true);
        
        Test.startTest();
        delete accts;
        Test.stopTest();

        List<Account> updatedAccounts = [SELECT Id FROM Account];
        System.assertEquals(0, updatedAccounts.size());
    }

    @isTest
    static void testUndelete() {
        System.debug('MDTriggerManagerTest.testUndelete()');
        List<Account> accts = makeAccounts(true);
        
        Test.startTest();
        delete accts;

        Database.undelete(accts, false);
        Test.stopTest();

        List<Account> updatedAccounts = [SELECT Id FROM Account];
        System.assertEquals(NUMBER_OF_TEST_ACCOUNTS, updatedAccounts.size());
    }
}