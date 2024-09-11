@IsTest
private class AccountWrapperTests {
  @TestSetup
  static void loadTestData() {
    // GIVEN
    Account acct = new Account(Name = 'ACME');
    insert acct;
    Account acct1 = new Account(Name = 'ACME1');
    insert acct1;

    Opportunity  oppRecord = new Opportunity(Name='Test',AccountId =acct.Id ,StageName= 'Perception Analysis',CloseDate=System.today() ,Amount =1000001);
    insert oppRecord;
    Opportunity  oppRecord1 = new Opportunity(Name='Test',AccountId =acct1.Id ,StageName= 'Perception Analysis',CloseDate=System.today() ,Amount =100);
    insert oppRecord1;
  }

  
  @IsTest
  static void testAllRoundedAveragePrice() {
    // WHEN
    Account acct = [SELECT Id FROM Account WHERE Name ='ACME1'  LIMIT 1 ];
    AccountWrapper acctWrapper = new AccountWrapper(acct);
    // THEN
    Test.startTest();
      Assert.areEqual(
        acctWrapper.getRoundedAvgPriceOfOpps(),
        1000.00,
        'Expected to get 1000.00');
    Test.stopTest();
  }

  @IsTest
  static void testPositiveRoundedAveragePrice() {
    // WHEN
    Account acct = [SELECT Id FROM Account WHERE Name ='ACME'  LIMIT 1 ];
    AccountWrapper acctWrapper = new AccountWrapper(acct);
    // THEN
    Test.startTest();
      Assert.areEqual(
        acctWrapper.getRoundedAvgPriceOfOpps(),
        1000000.0,
        'Expected to get 1000000.0');
    Test.stopTest();
  }

  @IsTest
  static void testIsHighPriority() {
    // WHEN
    Account acct = [SELECT Id FROM Account  WHERE Name !='ACME1' LIMIT 1];
    AccountWrapper acctWrapper = new AccountWrapper(acct);

    Account acct1 = [SELECT Id FROM Account  WHERE Name ='ACME1' LIMIT 1];
    AccountWrapper acctWrapper1 = new AccountWrapper(acct);
    // THEN
    Test.startTest();
        Assert.areEqual(acctWrapper.isHighPriority(),true,'Should Return true');
        Assert.areEqual(acctWrapper1.isHighPriority(),true,'Should Return false');
    Test.stopTest();
  }

}