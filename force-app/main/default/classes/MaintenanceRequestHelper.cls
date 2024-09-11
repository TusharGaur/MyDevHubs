public class MaintenanceRequestHelper {

    public static void processClosedRequests(List<Case> newList, List<Case> oldList) {
        // try {
            // Collect IDs of closed requests to handle
            Set<Id> closedRequestIds = new Set<Id>();
            Set<Id> equipmentId = new Set<Id>();
            List<Case> newCaseList = new  List<Case>();
            Map<Id,Case> mapIdVsCase = new  Map<Id,Case>();
            Map<Id,List<Product2>> mapCaseIdVsEquipment = new  Map<Id,List<Product2>>();
            Map<Id,Product2> mapIdVsEquipment = new  Map<Id,Product2>();
            Map<Id,List<Equipment_Maintenance_Item__c>> mapIdVsEquipmentItem = new  Map<Id,List<Equipment_Maintenance_Item__c>>();
            List<Equipment_Maintenance_Item__c> fetchAllMaintainanceItem = new List<Equipment_Maintenance_Item__c>();
            List<Equipment_Maintenance_Item__c> newListTOUpdate = new List<Equipment_Maintenance_Item__c>();
            // Iterate over the records to find closed requests
            for (Integer i = 0; i < newList.size(); i++) {
                Case newRequest = newList[i];
                Case oldRequest = oldList[i];
                if (oldRequest.Status != 'Closed' && newRequest.Status == 'Closed' && (newRequest.Type =='Repair' || newRequest.Type =='Routine Maintenance')) {
                    closedRequestIds.add(newRequest.Id);
                    mapIdVsCase.put(newList[i].Id, newList[i]);
                }
            }

            // // If no closed requests, exit
            // if (closedRequestIds.isEmpty()) {
            //     return;
            // }
            fetchAllMaintainanceItem = [SELECT Id,Name,Equipment__c,Quantity__c,Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN:closedRequestIds];
            if(!fetchAllMaintainanceItem.isEmpty()){
                for(Equipment_Maintenance_Item__c equipmentMaintenanceItem : fetchAllMaintainanceItem) {
                    equipmentId.add(equipmentMaintenanceItem.Equipment__c); 
                    if(!mapIdVsEquipmentItem.containsKey(equipmentMaintenanceItem.Maintenance_Request__c)){
                        mapIdVsEquipmentItem.put(equipmentMaintenanceItem.Maintenance_Request__c , new List<Equipment_Maintenance_Item__c>());
                    }
                    mapIdVsEquipmentItem.get(equipmentMaintenanceItem.Maintenance_Request__c).add(equipmentMaintenanceItem);
                }
            }
            // else{
            //     return;
            // }
            if(!equipmentId.isEmpty()){
                List<Product2> fetchedListOfAllEqipment =  new List<Product2> ();
                fetchedListOfAllEqipment = [SELECT Id,Name,Maintenance_Cycle__c FROM Product2 WHERE Id IN:equipmentId]; 
                for (Product2 productItem : fetchedListOfAllEqipment) {
                    mapIdVsEquipment.put(productItem.Id,productItem);
                }
            }
            // else{
            //     return;
            // }

            for (Equipment_Maintenance_Item__c item : fetchAllMaintainanceItem) {
                    if(!mapCaseIdVsEquipment.containsKey(item.Maintenance_Request__c)){
                        mapCaseIdVsEquipment.put(item.Maintenance_Request__c,new List<Product2>());
                    }
                    mapCaseIdVsEquipment.get(item.Maintenance_Request__c).add(mapIdVsEquipment.get(item.Equipment__c));
            }


            for (Id caseId : closedRequestIds) {
                Product2 equipmentItem = new Product2();
                Case closedCase = mapIdVsCase.get(caseId);
                List<Product2> eqipmentList = mapCaseIdVsEquipment.get(caseId);
                if(eqipmentList.size()>1){
                    equipmentItem = getRecordWithShortestInteger(eqipmentList,'Maintenance_Cycle__c');
                }else{
                    equipmentItem = eqipmentList[0];
                }
                Case newCase = new Case();
                newCase.Type = 'Routine Maintenance';
                newCase.Subject =  'Test';
                newCase.Date_Reported__c = Date.today();
                newCase.ParentId = closedCase.Id;
                newCase.Vehicle__c =  closedCase.Vehicle__c;
                newCase.Date_Due__c = Date.today().addDays(Integer.valueOf(equipmentItem.Maintenance_Cycle__c));    
                newCaseList.add(newCase);             
            }
            if(!newCaseList.isEmpty()){
                Insert newCaseList;
                for (Case newCaseItem : newCaseList) {
                    List<Equipment_Maintenance_Item__c>  oldEMIItems = new List<Equipment_Maintenance_Item__c>();
                    oldEMIItems =  mapIdVsEquipmentItem.get(newCaseItem.ParentId);
                    if(!oldEMIItems.isEmpty()){
                        for (Equipment_Maintenance_Item__c OLdEmiItem : oldEMIItems) {
                            Equipment_Maintenance_Item__c newEMI = new Equipment_Maintenance_Item__c();
                            newEMI.Maintenance_Request__c  = newCaseItem.Id;
                            newEMI.Equipment__c =  OLdEmiItem.Equipment__c;
                            newEMI.Quantity__c =  oldEMIItem.Quantity__c;
                            newListTOUpdate.add(newEMI);
                        }
                    }
                }
                if(!newListTOUpdate.isEmpty()){
                    INSERT newListTOUpdate;
                }
            }
        // } catch (Exception ex) {
        //     System.debug('ex line---->'+ex.getLineNumber());
        //     System.debug('ex message---->'+ex.getMessage());
        // }
    }


    public static Product2 getRecordWithShortestInteger(List<Product2> records, String fieldName) {
        // Handle the case where the list is empty
        if (records == null || records.isEmpty()) {
            return null;
        }

        Product2 minRecord = null;
        Integer minValue = null;

        // Iterate over each record to find the one with the smallest integer field value
        for (Product2 record : records) {
            // Get the integer field value using the field name provided
            Integer currentValue = Integer.valueOf(record.get(fieldName));
            if (currentValue != null && (minValue == null || currentValue < minValue)) {
                minValue = currentValue;
                minRecord = record;
            }
        }
        return minRecord;
    }
}