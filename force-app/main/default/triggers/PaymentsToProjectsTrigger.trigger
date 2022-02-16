trigger PaymentsToProjectsTrigger on Payments_to_Projects__c (
    before insert, before update, before delete, after insert, after update, after delete) {
        // roll up for projects
        Map<Id, Decimal> projectPaymentAmount = new Map<Id, Decimal>();
        // roll up for contacts
        Map<Id,Decimal> contactProjectExpenseAmount = new Map<Id, Decimal>();
        // map to populate most recent payment date on contact
        Map<Id, Date> mostRecentPaymentDateForClients = new Map<Id, Date>();

        // List of project Ids to query for
        List<Id> projectIdList = new List<Id>();
        // list of projects to update
        List<Project__c> projectList = new List<Project__c>();
        // List of contact Ids to query for
        List<Id> contactIdList = new List<Id>();
        // list of contacts to update
        List<Contact> contactList = new List<Contact>();
        // list of payments to calculate aggregated value
        List<Payments_to_Projects__c> paymentsList = new List<Payments_to_Projects__c>();
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                
            }
            if (Trigger.isUpdate) {
                
            }
            if (Trigger.isDelete) {
                
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                PaymentsToProjectsTriggerHandler.calculateClientValues(Trigger.new);
            }
            if (Trigger.isUpdate) {
                PaymentsToProjectsTriggerHandler.calculateClientValues(Trigger.new);
            }
            if (Trigger.isDelete) {
                PaymentsToProjectsTriggerHandler.calculateClientValues(Trigger.old);
                PaymentsToProjectsTriggerHandler.deleteEmptyParentPaymentRecords(Trigger.old);
            }
        }
        
        
        
        
      

}