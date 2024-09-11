@isTest
public without sharing class PermissionsTests {

    @TestSetup
    static void makeData(){
        Private_Object__c PbItem = new Private_Object__c (Name='TESTS');
        insert PbItem;
    }

    @isTest
    public static void testPositivePermissionSet() {
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'last',
            Email = 'Cpt.Awesome@awesomesauce.com',
            UserName = 'Cpt.Awesome.' + DateTime.now().getTime() + '@awesomesauce.com',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
          );
          insert u;

        PermissionSet ps = [
        SELECT Id
        FROM PermissionSet
        WHERE Name = 'Private_Object_Access'
        ];
        insert new PermissionSetAssignment(
        AssigneeId = u.Id,
        PermissionSetId = ps.Id
        );
          System.runAs(u) {
            // WHEN
            Test.startTest();
              Private_Object__c[] pos = [SELECT Id, Account__c, Notes__c FROM Private_Object__c];
            Test.stopTest();
            // THEN
            Assert.areEqual(
              1,
              pos.size(),
              'A user without the permission set shouldn\'t see any records');
          }
    }
}