global class WarehouseSyncSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        ID jobID = System.enqueueJob(new WarehouseCalloutService());
        //WarehouseCalloutService.runWarehouseEquipmentSync();
    }
}