import { LightningElement, track, wire, api } from 'lwc';
//import LightningDatatable from 'lightning/datatable';

// importing data from contact and payment objects for display
import SERVER_getContactsAndPayments from '@salesforce/apex/PaymentsToProjectsController.SERVER_getContactsAndPayments';
import SERVER_deleteProjectPayment from '@salesforce/apex/PaymentsToProjectsController.SERVER_deleteProjectPayment';
import SERVER_updateProjectPayment from '@salesforce/apex/PaymentsToProjectsController.SERVER_updateProjectPayment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const actions = [
   // { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Payment Name', fieldName: 'Name', type: 'string', editable: true},
    { label: 'Payment Date', fieldName: 'Payment_Date__c', type: 'date', editable: true },
    { label: 'Payment Amount', fieldName: 'Payment_Amount__c', type: 'currency', editable: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },}
];

export default class PresencePayments extends LightningElement {
    @track contactsList;
    @track error;
    @track deleteError;
    // contact id to track whcih contact the add payment buttons are linked
    @track contactId;
    @track isCreatePaymentModalOpen = false;
    @track isAddPaymentToProjectModalOpen = false;

    @api recordId;

    columns = columns;
    data = [];

    // ************************ Page Inits ************************
    connectedCallback() {
        this.handleLoad();
    }

    handleLoad() {
        SERVER_getContactsAndPayments()
        .then(result => {
            this.contactsList = result;
        })
        .catch(error => {
            this.error = error;
        });
    }
    // ***********************************************************************

    // ******************************* Button Click Handlers *****************************
    // Add Payment button is clicked
    addPaymentButtonClick(event) {
        // show create Presence_Payment__c record edit form
        this.contactId = event.currentTarget.name;
        // open record create modal
        this.isCreatePaymentModalOpen = true;

    }

    // Add Project Payment Button is clicked
    addProjectPaymentButtonClick(event) {
        // show create Payments_to_Projects__c record edit form
        this.contactId = event.currentTarget.name;
        // open create payment to project information modal
        this.isAddPaymentToProjectModalOpen = true;
    }

    handleRowAction(event) {
        var action = event.detail.action.name;
        console.log('-----data table action = '+action);
        const row = event.detail.row;
        
        switch (action) {
            case 'delete':
                this.deletePaymentProject(row);
                break;
            case 'edit':
                this.editPaymentProject(row);
                break;
            default:
        }
    }
    // ***********************************************************************


    // ************************** Payment CRUD Related Methods **************************
   

    // hanlde create payment record
    handleSavePayment(event) {
        // override default submit logic
        //event.preventDefault();
        // customSavePayment(event);
        
        // close the payment record create modal
        this.isCreatePaymentModalOpen = false;

        // refresh page view to get the latest change
        window.location.reload();
    }

    // handle create project payment record
    handleSaveProjectPayment(event) {
        const row = event.detail.row;
        var contactId = event.detail.Id;

        // close the project payment record create modal
        this.isAddPaymentToProjectModalOpen = false;
        // refresh page view to get teh latest change
        window.location.reload();
    }

    // method to throw success toast message on payment record create
    handlePaymentRecordCreateSuccess(event) {
        this.showSuccessToast('Payment Record Created Successfully.');
    }

    // method to throw success toast message on project payment junction record create
    handleProjectPaymentRecordCreateSuccess(event) {
        this.showSuccessToast('Payment added to Project Successfully.');
    }

    // method to handle inline edit on project payment record. Only the payment information is editable. 
    handlePaymentInlineEditSave(event) {
        console.log('------inside inline edit save');
        const row = event.detail.draftValues;
        console.log(row);
        console.log(row[0]);
        console.log(row[0]['Id']);
        SERVER_updateProjectPayment ({ projectPayment : row[0]})
        .then(result => {
            // force refresh page to see the change
            window.location.reload();
            this.showSuccessToast('Payment record updated succuessfully!');
        })
        .catch(error => {
            this.showErrorToast('Problem incurred in updating payment record.\nDetails: '+error);
        });
    }

    // method called when delete action is selected fhe drop down menu.
    deletePaymentProject(row) {
        SERVER_deleteProjectPayment({ projectPaymentId : row['Id']}) 
        .then(result => {
            // throw modal for success
            this.showSuccessToast('Payment deleted successfully!');

            // refresh page to show update
            window.location.reload();
        })
        .catch(error => {
            console.log('Error on delete');
            this.showErrorToast(error);
        });
        
    }

    // methods used in lightning record edit form for lookup fields. when a record is changed and 
    // you need the id of the newly pointed record to be captured, thid method will be leveraged.
    handleProjectLookUpOnCreate(event) {
        console.log('project Id = '+event.detail.value);
    }

    // another method used in lightning record edit form for look up fields. 
    handlePaymentLookUpOnCreate(event) {
        console.log('payment id ='+event.detail.value);
    }
    // ***********************************************************************

    // ************************* Modal Close Methods **************************
    closeCreatePaymentModal() {
        this.isCreatePaymentModalOpen = false;
    }
    closeAddPaymentToProjectModal() {
        this.isAddPaymentToProjectModalOpen = false;
    }
    // ***********************************************************************

    // ************************ Show Toast Methods ****************************
    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: this.message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: this.message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    // ***********************************************************************

}