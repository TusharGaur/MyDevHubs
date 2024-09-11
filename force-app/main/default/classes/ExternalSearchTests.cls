@isTest
public without sharing class ExternalSearchTests {
    @IsTest
    public static void  testpositiveMocking() {
        HTTPMockFactory mock = new HTTPMockFactory(200,'OK','I found it!',new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
            String result = ExternalSearch.googleIt('epic search');
        Test.stopTest();
        Assert.areEqual('I found it!', result, 'Expected to receive mock response');
    }
    @IsTest
    public static void  testNegativeMocking() {
        try {
            HTTPMockFactory mock1 = new HTTPMockFactory(500,'Not OK','Not found !',new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock1);
            Test.startTest();
                String result = ExternalSearch.googleIt('epic search');
            Test.stopTest();
            Assert.areEqual('Not found !', result, 'Expected to receive mock response');
        } catch (Exception ex) {
            Assert.areEqual('Did not receive a 200 status code: 500', ex.getMessage(), 'Expected to receive mock response');
        }
      
    }
    
}