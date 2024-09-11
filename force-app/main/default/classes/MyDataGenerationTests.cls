@isTest
public with sharing class MyDataGenerationTests {

    @TestSetup
    public static void loadTestDataFromStaticResource() {
        List<sObject> accounts = Test.loadData(Account.SObjectType, 'otherAccountData');
    }

    @isTest
    public static void testLoadOtherAccountsFromStaticResource(){
        List<Account> accList;
        Test.startTest();
        accList = [SELECT Id FROM Account];
        Test.stopTest();
        Assert.isTrue(accList.size() == 15, 'Expected 15 accounts');
    }
}