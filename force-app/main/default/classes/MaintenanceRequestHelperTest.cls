@isTest
public class MaintenanceRequestHelperTest {
    
    @testSetup
    static void setup() {
        // Create test Vehicles
        Vehicle__c vehicle1 = new Vehicle__c(Name = 'Test Vehicle 1', Air_Conditioner__c = true, Bathrooms__c = 1);
        Vehicle__c vehicle2 = new Vehicle__c(Name = 'Test Vehicle 2', Air_Conditioner__c = true, Bathrooms__c = 1);
        insert new List<Vehicle__c>{vehicle1, vehicle2};
        
        // Create test Products (Product2) with Maintenance_Cycle__c
        Product2 product1 = new Product2(Name = 'Equipment 1', Maintenance_Cycle__c = 30, Replacement_Part__c = true);
        Product2 product2 = new Product2(Name = 'Equipment 2', Maintenance_Cycle__c = 60, Replacement_Part__c = true);
        insert new List<Product2>{product1, product2};
        
        // Create test Cases
        Case case1 = new Case(Subject = 'Test Case 1', Status = 'Open', Type = 'Repair', Date_Reported__c = Date.today(), Vehicle__c = vehicle1.Id);
        Case case2 = new Case(Subject = 'Test Case 2', Status = 'Open', Type = 'Repair', Date_Reported__c = Date.today(), Vehicle__c = vehicle2.Id);
        insert new List<Case>{case1, case2};

        // Create Equipment_Maintenance_Item__c records linked to the test Cases
        Equipment_Maintenance_Item__c equipmentItem1 = new Equipment_Maintenance_Item__c(Equipment__c = product1.Id, Maintenance_Request__c = case1.Id, Quantity__c = 1);
        Equipment_Maintenance_Item__c equipmentItem2 = new Equipment_Maintenance_Item__c(Equipment__c = product2.Id, Maintenance_Request__c = case1.Id, Quantity__c = 1);
        Equipment_Maintenance_Item__c equipmentItem3 = new Equipment_Maintenance_Item__c(Equipment__c = product1.Id, Maintenance_Request__c = case2.Id, Quantity__c = 1);
        insert new List<Equipment_Maintenance_Item__c>{equipmentItem1, equipmentItem2, equipmentItem3};
    }
    
    @isTest
    static void testProcessClosedRequests_MultipleEquipmentItems() {
        // Fetch the test data
        List<Case> cases = [SELECT Id, Status, Type FROM Case WHERE Status = 'Open'];
        Case testCase = cases[0];
        
        // Simulate the case being closed
        Test.startTest();
        testCase.Status = 'Closed';
        update testCase;
        MaintenanceRequestHelper.processClosedRequests(new List<Case>{testCase}, cases);
        Test.stopTest();
        
        // Validate that a new Case was created
        List<Case> newCases = [SELECT Id, Type, ParentId FROM Case WHERE ParentId = :testCase.Id];
        System.assertEquals(1, newCases.size(), 'One new Case should have been created.');
        System.assertEquals('Routine Maintenance', newCases[0].Type, 'The new Case should have a Type of "Routine Maintenance".');
        
        // Validate that new Equipment_Maintenance_Item__c records were created
        List<Equipment_Maintenance_Item__c> newItems = [SELECT Id, Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :newCases[0].Id];
        System.assertEquals(2, newItems.size(), 'Two new Equipment_Maintenance_Item__c records should have been created.');
    }
    
    @isTest
    static void testProcessClosedRequests_SingleEquipmentItem() {
        // Fetch the test data
        List<Case> cases = [SELECT Id, Status, Type FROM Case WHERE Status = 'Open' AND Vehicle__c IN (SELECT Id FROM Vehicle__c WHERE Name = 'Test Vehicle 2')];
        Case testCase = cases[0];
        
        // Simulate the case being closed
        Test.startTest();
        testCase.Status = 'Closed';
        update testCase;
        MaintenanceRequestHelper.processClosedRequests(new List<Case>{testCase}, cases);
        Test.stopTest();
        
        // Validate that a new Case was created
        List<Case> newCases = [SELECT Id, Type, ParentId FROM Case WHERE ParentId = :testCase.Id];
        System.assertEquals(1, newCases.size(), 'One new Case should have been created.');
        System.assertEquals('Routine Maintenance', newCases[0].Type, 'The new Case should have a Type of "Routine Maintenance".');
        
        // Validate that one new Equipment_Maintenance_Item__c record was created
        List<Equipment_Maintenance_Item__c> newItems = [SELECT Id, Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :newCases[0].Id];
        System.assertEquals(1, newItems.size(), 'One new Equipment_Maintenance_Item__c record should have been created.');
    }
    
    @isTest
    static void testNoClosedRequests() {
        // Fetch the test data
        List<Case> cases = [SELECT Id, Status, Type FROM Case WHERE Status = 'Open'];
        
        // Simulate no cases being closed
        Test.startTest();
        MaintenanceRequestHelper.processClosedRequests(cases, cases);
        Test.stopTest();
        
        // Validate that no new Case was created
        List<Case> newCases = [SELECT Id, Type, ParentId FROM Case WHERE ParentId IN :cases];
        System.assertEquals(0, newCases.size(), 'No new Case should be created.');
    }
    
    @isTest
    static void testGetRecordWithShortestInteger() {
        // Fetch the test products
        List<Product2> products = [SELECT Id, Name, Maintenance_Cycle__c FROM Product2];
        
        // Call the helper method and validate the result
        Product2 minProduct = MaintenanceRequestHelper.getRecordWithShortestInteger(products, 'Maintenance_Cycle__c');
        System.assertEquals('Equipment 1', minProduct.Name, 'The product with the shortest Maintenance Cycle should be Equipment 1.');
    }

    @isTest
    static void testGetRecordWithShortestInteger_NullList() {
        // Call the helper method with a null list
        Product2 minProduct = MaintenanceRequestHelper.getRecordWithShortestInteger(null, 'Maintenance_Cycle__c');
        System.assertEquals(null, minProduct, 'The result should be null when the input list is null.');
    }

}