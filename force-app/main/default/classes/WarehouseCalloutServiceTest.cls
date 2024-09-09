@isTest
private class WarehouseCalloutServiceTest {

    @testSetup
    static void setup() {
        // Any setup data if needed can be inserted here
    }

    @isTest
    static void testWarehouseCallout_Success() {
        // Set up the mock callout for a successful response
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        // Execute the method
        Test.startTest();
        WarehouseCalloutService.runWarehouseEquipmentSync();
        ID jobID = System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();
        
        // Validate that Product2 records were upserted
        List<Product2> products = [SELECT Name, Warehouse_SKU__c FROM Product2];
        System.assertEquals(1, products.size(), 'There should be 1 Product2 record upserted.');
        System.assertEquals('Generator 1000 kW', products[0].Name, 'The product name should be Generator 1000 kW.');
    }

    @isTest
    static void testWarehouseCallout_Failure() {
        // Set up the mock callout to simulate a failed response
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceFailureMock());
        
        // Execute the method
        Test.startTest();
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        
        // Validate that no Product2 records were upserted
        List<Product2> products = [SELECT Name FROM Product2];
        System.assertEquals(0, products.size(), 'There should be no Product2 records upserted due to the failed callout.');
    }

    @isTest
    static void testWarehouseCallout_EmptyResponse() {
        // Set up the mock callout to return an empty response
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceEmptyMock());
        
        // Execute the method
        Test.startTest();
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        
        // Validate that no Product2 records were upserted
        List<Product2> products = [SELECT Name FROM Product2];
        System.assertEquals(0, products.size(), 'There should be no Product2 records upserted because the response was empty.');
    }
}