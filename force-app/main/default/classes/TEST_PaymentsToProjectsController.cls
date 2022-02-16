@isTest
public with sharing class TEST_PaymentsToProjectsController {
    
    //create TEST Account 
    public static Account createAccount() {
        Account testAccount = new Account(Name='Test Account');
        
        insert testAccount;
        
        return testAccount;
    }

    // create 5 contact records
    public static List<Contact> createContactList() {
        Account testAccount = createAccount();
        List<Contact> contactList = new List<Contact>();
        Map<String,String> contactNames = new Map<String,String>{'John' => 'Smith', 
                                                            'Brenda' => 'Morris', 
                                                            'Clifford' => 'Grant', 
                                                            'Pete' => 'Williams', 
                                                            'Sam' => 'Douglas'};

        for (String firstName : contactNames.keySet()) {
            Contact con = new Contact(AccountId = testAccount.Id, FirstName = firstName, LastName = contactNames.get(firstName));
            contactList.add(con);
        }
        
        insert contactList;
        
        return contactList;
    }

    // create 1 contact record
    public static Contact createContact() {
        Account testAccount = createAccount();
        Contact con = new Contact(AccountId=testAccount.Id, FirstName='Elon', LastName='Musk');

        insert con;
        
        return con;
    }

    // create 10 projects
    public
    static List<Project__c> createProjectList() {
        List<Project__c> projectList = new List<Project__c>();
        
        for (Integer i = 0; i < 10; i++) {
            Project__c project = new Project__c(Name = 'Test Project'+i, Project_Type__c='Internal', Start_Date__c=Date.TODAY());
            projectList.add(project);
        }

        insert projectList;
        
        return projectList;
    }

    // create parent payment record
    public static List<Presence_Payment__c> createPaymentList(List<Contact> contactList) {
        List<Presence_Payment__c> paymentList = new List<Presence_Payment__c>();
        Integer i = 0;

        for(Contact con : contactList ) {
            Presence_Payment__c payment = new Presence_Payment__c(Name = 'test '+i, Payment_Transaction_Identifier__c = 'BOACC00'+i, Payment_Source__c = 'BOA', Payer__c = con.Id);
            paymentList.add(payment);
        }

        insert paymentList;
        
        return paymentList;
    }

    // method to create project payment record
    public static Payments_To_Projects__c createProjectPayment(String name, Decimal amount, Date paymentDate) {
        // set up data
        Contact con = createContact();
        // create payment record
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);

        Presence_Payment__c payment = createPaymentList(contactList)[0]; // bad practise
        // create project
        Project__c project = createProjectList()[0]; // bad practise

        // create payments to projects record. should check for null
        Payments_To_Projects__c projectPayment = new Payments_To_Projects__c(Name = name,
                                                                            Payer__c = con.Id,
                                                                            Presence_Payment__c = payment.Id,
                                                                            Project__c = project.Id,
                                                                            Payment_Amount__c = amount,
                                                                            Payment_Date__c = paymentDate);
        // inserting the test payment to project
        insert projectPayment;

        return projectPayment;
    }

    /**
     *  Method to test SERVER_deleteProjectPayment
     */
    @isTest static void test_SERVER_deleteProjectPayment() {
        // creating  payment to project record
        Payments_To_Projects__c projectPayment = createProjectPayment('test project payment', 35000, Date.TODAY());
        
        // saving the payment id separately for assert
        Id deletedPaymentId = projectPayment.Id;

        // calling the server method for deletion
        PaymentsToProjectsController.SERVER_deleteProjectPayment(deletedPaymentId);
        //delete projectPayment;

        // testing
        List<Payments_to_Projects__c> projectPaymentList = [Select Id, Name, Payment_Amount__c From Payments_to_Projects__c WHere Id = :deletedPaymentId ALL ROWS];
        System.assert(projectPaymentList.size() > 0, 'Project Payment did not get deleted!');
        
    }

    /**
     * Method to test SERVER_updateProjectPayment
     */
    @isTest static void test_SERVER_updateProjectPayment() {
        Decimal paymentOneAmount = 40000;
        Decimal updatedAmount = 50000;
        Decimal paymentTwoAmount = 34000;
        // creating payment to project record
        Payments_To_Projects__c projectPaymentOne = createProjectPayment('test project Payment 1', paymentOneAmount, Date.TODAY());
        Payments_To_Projects__c projectPaymentTwo = createProjectPayment('test project Payment 1', paymentTwoAmount, Date.TODAY());

        // updating project Payment amount
        projectPaymentOne.Payment_Amount__c = updatedAmount;
        
        PaymentsToProjectsController.SERVER_updateProjectPayment(projectPaymentOne);

        List<Id> contactIdList = new List<Id>{projectPaymentOne.Payer__c, projectPaymentTwo.Payer__c};
        // query contact to see if the update has been reflected in the amount field. 
        List<Contact> relatedContactList = [Select Id, Project_Expense_Amount__c From Contact Where Id IN :contactIdList];
        Decimal expectedAmount = updatedAmount + paymentTwoAmount ;
        Decimal actualAmount = 0;
        
        for (Contact con : relatedContactList) {
            actualAmount = actualAmount + con.Project_Expense_Amount__c;
        }

        // check if amount totals to expected amount
        System.assertEquals(expectedAmount, actualAmount, 'Total amount on contact = '+actualAmount+' The expected amount ='+expectedAmount);


    }

}