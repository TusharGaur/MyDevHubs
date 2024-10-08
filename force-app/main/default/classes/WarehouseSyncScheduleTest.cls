@isTest
public class WarehouseSyncScheduleTest {
   
    @isTest static void WarehousescheduleTest(){
        String scheduleTime = '00 00 01 * * ?';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String jobID = System.schedule('Warehouse Time To Schedule to Test', scheduleTime, new WarehouseSyncSchedule());
        Test.stopTest();
        //Contains schedule information for a scheduled job. CronTrigger is similar to a cron job on UNIX systems.
        // This object is available in API version 17.0 and later.
        Set<Id> jobIId = new Set<Id>();
        List<CronTrigger> a=[SELECT Id FROM CronTrigger where NextFireTime > today];
        for (CronTrigger variable : a) {
            jobIId.add(variable.Id);
        }
        System.assertEquals(true, jobIId.contains(jobID),'Schedule ');
    }
}