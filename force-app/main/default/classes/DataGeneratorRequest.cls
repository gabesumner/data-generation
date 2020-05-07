public with sharing class DataGeneratorRequest {
    
    // Type of record to generate (Example: accounts, contacts, cases)
    @AuraEnabled
    public String recordType {
        get { return (recordType == null) ? '' : recordType.toLowerCase(); }
        set { recordType = value; }
    }

    // Subtype of record to generate (Example: business, consumer)
    @AuraEnabled
    public String subType {
        get { return (subType == null) ? '' : subType.toLowerCase(); }
        set { subType = value; }
    }

    // How many records to generate when no parent is involved (Example: 4000)
    @AuraEnabled
    public Integer recordsToGenerate {
        get { return (recordsToGenerate == null) ? 0 : recordsToGenerate; }
        set { recordsToGenerate = value; }
    }

    // Minimum number of records to generate per parent (Example: 1)
    @AuraEnabled
    public Integer minRecordsToGeneratePerParent {
        get { return (minRecordsToGeneratePerParent == null) ? 0 : minRecordsToGeneratePerParent; }
        set { minRecordsToGeneratePerParent = value; }
    }
    
    // Maximum number of records to generate per parent (Example: 5)
    @AuraEnabled
    public Integer maxRecordsToGeneratePerParent {
        get { return (maxRecordsToGeneratePerParent == null) ? 0 : maxRecordsToGeneratePerParent; }
        set { maxRecordsToGeneratePerParent = value; }
    }

    // The current parent record as we interate through all parent records.
    @AuraEnabled
    public Integer currentParent {
        get { return (currentParent == null) ? 0 : currentParent; }
        set { currentParent = value; }
    }

    // How many records we're generating for the current parent we're processing.
    @AuraEnabled
    public Integer recordsToGenerateForCurrentParent {
        get { return (recordsToGenerateForCurrentParent == null) ? 0 : recordsToGenerateForCurrentParent; }
        set { recordsToGenerateForCurrentParent = value; }
    }

    // How many records we've processed for the current parent.
    @AuraEnabled
    public Integer recordsGeneratedForCurrentParent {
        get { return (recordsGeneratedForCurrentParent == null) ? 0 : recordsGeneratedForCurrentParent; }
        set { recordsGeneratedForCurrentParent = value; }
    }

    // How many records we've generated total.
    @AuraEnabled
    public Integer totalRecordsGenerated {
        get { return (totalRecordsGenerated == null) ? 0 : totalRecordsGenerated; }
        set { totalRecordsGenerated = value; }
    }

    @AuraEnabled
    public Boolean maxRecordsExceeded {
        get { return (maxRecordsExceeded == null) ? false : maxRecordsExceeded; }
        set { maxRecordsExceeded = value; }

    }
}
