/***************************************************
 * @Class Name: PaymentsToProjectsTriggerHandler
 * @Description: Handler class for PaymentsToProjectsTrigger
 * @Author: Pratibha Sundar
 * @Version: 1.0
***************************************************/
public class PaymentsToProjectsTriggerHandler {
    public PaymentsToProjectsTriggerHandler() {
        
    }
    /**
     * @param paymentsToProjectsList - List of payments to projects object that is from trigger
     * 
     * This method gets all the related list of contacts and projects for the payments to projects list from trigger. 
     * Then, it queries for all the relevant payments to projects, seperate the list for contacts and projects. Finally, 
     * it aggregates the values to populate the totals in Project and Contact objects.  
     */
    public static void calculateClientValues(List<Payments_to_Projects__c> paymentsToProjectsList) {
        System.debug('------1-- inside calculateClientValues');
        List<Payments_to_Projects__c> allPaymentsToProjects = new List<Payments_to_Projects__c>();
        Set<Id> payerIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Map<String,List<Payments_to_Projects__c>> contactPTPMap = new Map<String,List<Payments_to_Projects__c>>();
        Map<String,List<Payments_to_Projects__c>> projectPTPMap = new Map<String,List<Payments_to_Projects__c>>();
        List<Contact> contactListToUpdate = new List<Contact>();
        List<Project__c> projectListToUpdate = new List<Project__c>();
        
        System.debug('------2-- inside calculateClientValues');
        for (Payments_to_Projects__c ptp :paymentsToProjectsList) {
            payerIdSet.add(ptp.Payer__c);
            projectIdSet.add(ptp.Project__c);
        }
        
        allPaymentsToProjects = [SELECT Id, Payer__c, Project__c, Payment_Amount__c, Payment_Date__c 
                                 FROM Payments_to_Projects__c
                                 WHERE Payer__c IN :payerIdSet OR Project__c IN :projectIdSet];
        system.debug('Size: '+allPaymentsToProjects.size());
        
        System.debug('------3-- inside calculateClientValues');
        //Populate maps for contact to PTP and Project to PTP
        for (Payments_to_Projects__c ptp : allPaymentsToProjects) {

            // considering only payments associated with contact relevant to payments from trigger
            if (payerIdSet.contains(ptp.Payer__c)) { 
                if (!contactPTPMap.containsKey(ptp.Payer__c)) {
                    contactPTPMap.put(ptp.Payer__c,new List<Payments_to_Projects__c>());
                }
                contactPTPMap.get(ptp.Payer__c).add(ptp);
            }
            
            // considering only payments associated with projects relevant to payments from trigger
            if (projectIdSet.contains(ptp.Project__c)) {
                if (!projectPTPMap.containsKey(ptp.Project__c)) {
                    projectPTPMap.put(ptp.Project__c,new List<Payments_to_Projects__c>());
                }
            
                projectPTPMap.get(ptp.Project__c).add(ptp);
            }
        }
         
        system.debug('Size2: '+contactPTPMap.size());
        //Iterate through contact PTP Map and calculate TotalPayment and recent payment date for each contact and update contact records
        for (String payerId : contactPTPMap.keySet()) {
            Decimal totalPayment = 0.00;
            Date recentPaymentDate;
            for (Payments_to_Projects__c ptp : contactPTPMap.get(payerId)) {
                system.debug('Payment Amount: '+ptp.Payment_Amount__c);
                totalPayment = totalPayment + ptp.Payment_Amount__c;
                if (recentPaymentDate == null || (recentPaymentDate !=null && ptp.Payment_Date__c > recentPaymentDate)) {
                    recentPaymentDate = ptp.Payment_Date__c;
                }
            }
            Contact contactToUpdate = new Contact();
            contactToUpdate.Id = payerId;
            contactToUpdate.Most_Recent_Payment_Date__c = recentPaymentDate;
            contactToUpdate.Project_Expense_Amount__c = totalPayment;
            contactListToUpdate.add(contactToUpdate);
            
        }
        update contactListToUpdate;
        System.debug('------4-- inside calculateClientValues');
        
        //Iterate through project PTP Map and calculate TotalPayment and recent payment date for each project and update project records
        for (String projectId : projectPTPMap.keySet()) {
            Decimal totalPayment = 0.00;
            for (Payments_to_Projects__c ptp : projectPTPMap.get(projectId)) {
                totalPayment = totalPayment + ptp.Payment_Amount__c;
            }
            Project__c projectsToUpdate = new Project__c();
            projectsToUpdate.Id = projectId;
            projectsToUpdate.Revenue__c = totalPayment;
            projectListToUpdate.add(projectsToUpdate);
            
        }
        System.debug('------5-- inside calculateClientValues');
        
        update projectListToUpdate;
        
    }

    /**
     * @param deletedProjectPaymentList : List of deleted Project Payment records from the after delete trigger. 
     * 
     * This method checks if there are any orphaned parent Payment record due to deleting the junction object's record.
     * When all the child payments for a given payment record is deleted, check if the parent has any child record left in the junction object.
     * If not, then, delete parent.
     */
    public static void deleteEmptyParentPaymentRecords(List<Payments_to_Projects__c> deletedProjectPaymentList) {
        Set<Id> paymentIdSet = new Set<Id>();
        
        // get all the parent payment record id from deleted junction object
        for (Payments_to_Projects__c projectPayment : deletedProjectPaymentList) {
            paymentIdSet.add(projectPayment.Presence_Payment__c);
        }

        // check if there is any empty payment record.
        // get all the child records for the payment records associated with the deleted junction object 
        List<Payments_to_Projects__c> projectPaymentList = [Select Id, Presence_Payment__c From Payments_to_Projects__c Where Presence_Payment__c IN :paymentIdSet];

        // iterate
        for (Payments_to_Projects__c ptp : projectPaymentList) {
            if (paymentIdSet.contains(ptp.Presence_Payment__c)) {
                // this payment record still has child payments. so, no need to delete this
                paymentIdSet.remove(ptp.Presence_Payment__c);
            }
        }

        // if there is any payment record in the set, they are the orphaned record. delete this
        List<Presence_Payment__c> paymentDeleteList = new List<Presence_Payment__c>();
        for (Id paymentId : paymentIdSet) {
            Presence_Payment__c pp = new Presence_Payment__c (Id = paymentId);
            paymentDeleteList.add(pp);
        }

        // if there are any orphaned parent record, delete
        if (paymentDeleteList.size() > 0) {
            delete paymentDeleteList;
        }

        // [TO DO] - recalculate Payment object's roll up summary field
    }
}