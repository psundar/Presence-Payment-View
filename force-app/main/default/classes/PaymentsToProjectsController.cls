public with sharing class PaymentsToProjectsController {
    public PaymentsToProjectsController() {

        

    }

    
    
    // utility method to get the most recent payment date from given dates
  /*  public static Map<Id, Date> getMostRecentPaymentDateForContacts(List<Payments_to_Projects__c> paymentsList) {
        Map<Id, Date> contactsToMostRecentPaymentDateMap = new Map<Id, Date>();
        
        for (Payments_to_Projects__c payment : paymentsList) {
            Id clientId = payment.Payer__c;
            if (contactsToMostRecentPaymentDateMap.containsKey(clientId)) {
                // if the existing payment date in map is less than the current payment date, then update the map with the most recent.
                if (contactsToMostRecentPaymentDateMap.get(clientId) < payment.Payment_Date__c) {
                    contactsToMostRecentPaymentDateMap.put(clientId, payment.Payment_Date__c);
                    
                }
            } else {
                // if the map is new, then populate it with the current payment date
                contactsToMostRecentPaymentDateMap.put(clientId, payment.Payment_Date__c);
            }
            
        }

        return contactsToMostRecentPaymentDateMap;
    }
    
    // utility method to get the aggregated payment amount on project
    public static Map<Id, Decimal> getTotalProjectAmount(List<Payments_to_Projects__c> paymentsList) {
        Map<Id, Decimal> projectToPaymentAmountMap = new Map<Id, Decimal>();

        for (Payments_to_Projects__c payment : paymentsList) {
            Id projectId = payment.Project__c;
            Decimal paymentAmount = payment.Payment_Amount__c;
            Decimal totalProjectAmount = 0;

            if (projectToPaymentAmountMap.containsKey(projectId)) {
                totalProjectAmount = projectToPaymentAmountMap.get(projectId) + paymentAmount;
            } else {
                totalProjectAmount = paymentAmount;
            }

            projectToPaymentAmountMap.put(projectId, totalProjectAmount);
        }

        return projectToPaymentAmountMap;
    }

    //utility method to get the aggregate payment amount on contact
    public static Map<Id, Decimal> getTotalExpenseAmount(List<Payments_to_Projects__c> paymentsList) {
        Map<Id, Decimal> clientToPaymentAmountMap = new Map<Id, Decimal>();

        for (Payments_to_Projects__c payment : paymentsList) {
            Id clientId = payment.Payer__c;
            Decimal paymentAmount = payment.Payment_Amount__c;
            Decimal totalExpenseAmount = 0;
            
            if (clientToPaymentAmountMap.containsKey(clientId)) {
                totalExpenseAmount = clientToPaymentAmountMap.get(clientId) + paymentAmount;
            } else {
                totalExpenseAmount = paymentAmount;
            }
            clientToPaymentAmountMap.put(clientId, totalExpenseAmount);
        }

        return clientToPaymentAmountMap;
    }
*/
    public static List<Contact> getContactsAndPayments() {

        List<Contact> contactAndPaymentList = [Select Id, Name, Most_Recent_Payment_Date__c, Project_Expense_Amount__c, 
                                                            (SELECT Id, Name, Project__c, Payment_Date__c, Presence_Payment__r.Payment_Transaction_Identifier__c, Presence_Payment__r.Payment_Source__c,  Payment_Amount__c From Payments_To_Projects__r)
                                                            From Contact Where Id in (Select Payer__c From Presence_Payment__c)];
        return contactAndPaymentList;

    }

    
    /**
     * Server method to get contact information and their related payments for project information.
     */
    @AuraEnabled(cacheable=true)
    public static List<Contact> SERVER_getContactsAndPayments() {
        try {
            List<Contact> contactAndPaymentList = getContactsAndPayments();
            return contactAndPaymentList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Server method to update Payments_to_Projects object from the UI's inline edit.
     * @param projectPayment : Instance of the project payment junction object that needs to be updated.
     */
    @AuraEnabled
    public static void SERVER_updateProjectPayment(Payments_To_Projects__c projectPayment) {
        try {

            // update project payment
            Update projectPayment;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Server method to delete project payment junction object
     * @param  projectPaymentId : Id of the junction object Payments to Projects which needs to be deleted 
     */
    @AuraEnabled
    public static void SERVER_deleteProjectPayment(Id projectPaymentId){
        try {
            
            //creating the instance of payments to project junction object for deletion
            Payments_To_Projects__c projectPayment = new Payments_To_Projects__c(Id = projectPaymentId);
            
            delete projectPayment;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    

}