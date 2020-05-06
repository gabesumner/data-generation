import { LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi'
import callGenerateAccounts from '@salesforce/apex/DataGenerator.generateAccounts';
import callGenerateContactsForAccounts from '@salesforce/apex/DataGenerator.generateContactsForAccounts';
import callGenerateCasesForContacts from '@salesforce/apex/DataGenerator.generateCasesForContacts';
import callDeleteAll from '@salesforce/apex/DataGenerator.DeleteAll';

export default class DataGenerator extends LightningElement {
    @track accountsToGenerate = 5;
    @track casesToGenerate = '1-10';
    @track recordType = 'account';
    @track accountType = 'consumer';
    @track minimumContactsToGenerate = 1;
    @track maximumContactsToGenerate = 5;
    @track minimumCasesToGenerate = 1;
    @track maximumCasesToGenerate = 5;    
    @track openmodel = false;
    @track log = "";
    error;
    subscription = {};

    get recordTypeOptions() {
        return [
            {label: 'Accounts', value: 'account'},
            {label: 'Contacts for All Accounts', value: 'contact'},
            {label: 'Cases for All Contacts', value: 'case'}
        ];
    }

    get accountTypeOptions() {
        return [
            {label: 'Consumer', value: 'consumer'},
            {label: 'Business', value: 'business'},
            {label: 'Both', value: 'both'}
        ];
    }

    handleRecordTypeChange(event) {
        this.recordType = event.detail.value;
    }

    handleAccountTypeChange(event) {
        this.accountType = event.detail.value;
    }

    handleAccountsToGenerate(event) {
        this.accountsToGenerate = event.detail.value;
    }

    handleMinimumContactsToGenerate(event) {
        this.minimumContactsToGenerate = event.detail.value;
    }

    handleMaximumContactsToGenerate(event) {
        this.maximumContactsToGenerate = event.detail.value;
    }

    handleMinimumCasesToGenerate(event) {
        this.minimumCasesToGenerate = event.detail.value;
    }

    handleMaximumCasesToGenerate(event) {
        this.maximumCasesToGenerate = event.detail.value;
    }
    
    handleGenerateRecords(event) {
        this.openmodal();

        switch(this.recordType) {
            case 'account':
                var request = {
                    'subType': this.accountType,
                    'recordsToGenerate': this.accountsToGenerate
                }
                this.generateAccounts(request);
                break;
            case 'contact':
                var request = {
                    'minRecordsToGeneratePerParent': this.minimumContactsToGenerate,
                    'maxRecordsToGeneratePerParent': this.maximumContactsToGenerate
                }
                this.generateContactsForAccounts(request);
                break;
            case 'case':
                var request = {
                    'minRecordsToGeneratePerParent': this.minimumCasesToGenerate,
                    'maxRecordsToGeneratePerParent': this.maximumCasesToGenerate
                }
                this.generateCasesForContacts(request);
                break;
        }

    }

    generateAccounts(request) {
        callGenerateAccounts({
            request: request
        })
        .then(result => {
            console.log(JSON.stringify(result));

            request = result;
            console.log('result: ' + request.totalRecordsGenerated + ':' + request.recordsToGenerate);
            if (request.totalRecordsGenerated < request.recordsToGenerate) {
                this.generateAccounts(request);
            }
        })
        .catch(error => {
            this.addToLog('ERROR: ' + JSON.stringify(error));
            this.error = error;
        });
    }

    generateContactsForAccounts(request) {
        callGenerateContactsForAccounts({
            request: request
        })
        .then(result => {
            console.log(JSON.stringify(result));
            request = result;
            console.log('result: ' + request.totalRecordsGenerated + ':' + request.recordsToGenerate);
            if (request.maxRecordsExceeded == true) {
                this.generateContactsForAccounts(request);
            }
        })
        .catch(error => {
            console.log('ERROR: ' + JSON.stringify(error));
            this.addToLog('ERROR: ' + error.body.message);
            this.error = error;
        });
    }

    generateCasesForContacts(request) {
        callGenerateCasesForContacts({
            request: request
        })
        .then(result => {
            console.log(JSON.stringify(result));
            request = result;
            console.log('result: ' + request.totalRecordsGenerated + ':' + request.recordsToGenerate);
            if (request.maxRecordsExceeded == true) {
                this.generateCasesForContacts(request);
            }
        })
        .catch(error => {
            console.log('ERROR: ' + JSON.stringify(error));
            this.addToLog('ERROR: ' + error.body.message);
            this.error = error;
        });      
    }

    deleteAll(event) {
        this.openmodal();
        this.addToLog('START: Deleting ALL records.');

        callDeleteAll({})
        .then(result => {
            if (result == false) {
                this.deleteAll();
            }
        })
        .catch(error => {
            console.log('Error: ' + JSON.stringify(error));
            this.error = error;
        });           
    }

    openmodal() {
        this.log = '';

        // Callback invoked whenever a new event message is received
        const messageCallback = function(response) {
            //this.addToLog(JSON.stringify(response));
            this.addToLog(response.data.payload.Message__c);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe('/event/Data_Generator_Event__e', -1, messageCallback.bind(this)).then(response => {
            this.subscription = response;
        }); 

        this.openmodel = true;
    }

    closeModal() {
        this.openmodel = false;

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            this.addToLog('unsubscribe() response: ' + JSON.stringify(response));
        });
    }

    addToLog(message) {
        console.log(message);
        var today = new Date(); 
        var time = 
            (today.getHours()<10?'0':'') + today.getHours() + ':' +
            (today.getMinutes()<10?'0':'') + today.getMinutes() + ':' +
            (today.getSeconds()<10?'0':'') + today.getSeconds();
                
        this.log = time + ": " + message + "\n" + this.log;
    }

    get isAccount() {
        if (this.recordType === 'account') {
            return true;
        } else {
            return false;
        }
    }

    get isContact() {
        if (this.recordType === 'contact') {
            return true;
        } else {
            return false;
        }        
    }

    get isCase() {
        if (this.recordType === 'case') {
            return true;
        } else {
            return false;
        }        
    }    
}