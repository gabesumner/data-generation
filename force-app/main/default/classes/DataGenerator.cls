public with sharing class DataGenerator {
    @AuraEnabled
    public static DataGeneratorRequest generateAccounts(DataGeneratorRequest request) {

        if (request.totalRecordsGenerated == 0) {
            publishEvent('START: Generating ' + request.recordsToGenerate + ' accounts...');
        }

        List<String> firstNames = getFirstNames();
        List<String> lastNames = getLastNames();
        List<String> addresses = getAddresses();
        List<Account> accounts = new List<Account>();
        Integer recordCount = 0;

        while (request.totalRecordsGenerated < request.recordsToGenerate && recordCount < maxRecordsToProcessPerRequest) {
            switch on request.subtype {
                when 'consumer' {
                    accounts.add(createConsumerAccount(firstNames, lastNames, addresses));
                }
                when 'business' {
                    accounts.add(createBusinessAccount(lastNames, addresses));
                }
                when else {
                    if (getRandomBoolean() == true) {
                        accounts.add(createConsumerAccount(firstNames, lastNames, addresses));
                    } else {
                        accounts.add(createBusinessAccount(lastNames, addresses));
                    }    
                }
            }

            recordCount = recordCount + 1;
            request.totalRecordsGenerated = request.totalRecordsGenerated + 1;

            if (accounts.size() >= maxRecordsToProcessPerInsert) {
                insert accounts;
                publishEvent('Generated ' + request.totalRecordsGenerated + ' accounts.' );
                accounts.clear();
            }
        }
        insert accounts;

        if (request.totalRecordsGenerated >= request.recordsToGenerate) {
            request.maxRecordsExceeded = false;
            publishEvent('FINISH: Generated ' + request.totalRecordsGenerated + ' accounts.');
        } else {
            request.maxRecordsExceeded = true;
        }

        return request;
    }

    @AuraEnabled
    public static DataGeneratorRequest generateContactsForAccounts(DataGeneratorRequest request) {
        if (request.currentParent == 0 && request.totalRecordsGenerated == 0) {
            publishEvent('START: Generating ' + request.minRecordsToGeneratePerParent + '-' + request.maxRecordsToGeneratePerParent + ' contacts for each account...');
        }

        List<String> firstNames = getFirstNames();
        List<String> lastNames = getLastNames();
        List<String> addresses = getAddresses();
        List<Account> accounts = [SELECT Id, Name, Phone, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, NumberOfEmployees FROM Account LIMIT :maxRecordsToProcessPerRequest OFFSET :request.currentParent];
        List<Contact> contacts = new List<Contact>();
        Integer parentCount = 0;
        Integer recordCount = 0;

        while (parentCount < accounts.size() && recordCount < maxRecordsToProcessPerRequest) {

            // We might be resuming processing of an existing request that was interupted due to single request limits.
            if (parentCount != 0 || request.recordsToGenerateForCurrentParent == 0) {
                request.recordsToGenerateForCurrentParent = getRandomInt(request.minRecordsToGeneratePerParent, request.maxRecordsToGeneratePerParent);
                request.recordsGeneratedForCurrentParent = 0;
            }

            // Loop through each parent until we're finished OR until we encounter the maximum number of records we can process in a single request
            while (request.recordsGeneratedForCurrentParent < request.recordsToGenerateForCurrentParent && recordCount < maxRecordsToProcessPerRequest) {
                contacts.add(createContact(accounts[parentCount], firstNames, lastNames, addresses));
                recordCount = recordCount + 1;
                request.recordsGeneratedForCurrentParent = request.recordsGeneratedForCurrentParent + 1;
                request.totalRecordsGenerated = request.totalRecordsGenerated + 1;
                if (contacts.size() >= maxRecordsToProcessPerInsert) {
                    insert contacts;
                    publishEvent('Generated ' + request.totalRecordsGenerated + ' contact records for ' + String.valueOf(request.currentParent + 1) + ' accounts.' );
                    contacts.clear();
                }
            }

            // If we haven't yet inserted the maximum number of records OR we've successfully created all the required records for the CURRENT parent, then increment our counter variables.
            if (contacts.size() < maxRecordsToProcessPerRequest || request.recordsGeneratedForCurrentParent >= request.recordsToGenerateForCurrentParent) {
                parentCount = parentCount + 1;
                request.currentParent = request.currentParent + 1;
            }

            // If we've generated the required number of records for the current parent, then reset the records required to generate.
            if (request.recordsGeneratedForCurrentParent >= request.recordsToGenerateForCurrentParent ) {
                request.recordsToGenerateForCurrentParent = 0;
                request.recordsGeneratedForCurrentParent = 0;
            }            
        }
        insert(contacts);

        if (parentCount >= accounts.size() && request.currentParent < maxRecordsToProcessPerRequest) {
            request.maxRecordsExceeded = false;
            publishEvent('FINISH: Generated ' + request.totalRecordsGenerated + ' contacts for ' + request.currentParent + ' accounts.');
        } else {
            request.maxRecordsExceeded = true;
        }

        return request;
    }

    @AuraEnabled
    public static DataGeneratorRequest generateCasesForContacts(DataGeneratorRequest request) {
        System.debug('generateCasesForContacts 1');
        if (request.currentParent == 0 && request.totalRecordsGenerated == 0) {
            publishEvent('START: Generating ' + request.minRecordsToGeneratePerParent + '-' + request.maxRecordsToGeneratePerParent + ' cases for each contact...');
        }

        System.debug('generateCasesForContacts 2');
        List<Case> cases = new List<Case>();
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact LIMIT :maxRecordsToProcessPerRequest OFFSET :request.currentParent];
        Integer parentCount = 0;
        Integer recordCount = 0;        

        System.debug('generateCasesForContacts 3');
        while (parentCount < contacts.size() && recordCount < maxRecordsToProcessPerRequest) {

            // We might be resuming processing of an existing request that was interupted due to single request limits.
            if (parentCount != 0 || request.recordsToGenerateForCurrentParent == 0) {
                request.recordsToGenerateForCurrentParent = getRandomInt(request.minRecordsToGeneratePerParent, request.maxRecordsToGeneratePerParent);
                request.recordsGeneratedForCurrentParent = 0;
            }

            // Loop through each parent until we're finished OR until we encounter the maximum number of records we can process in a single request
            while (request.recordsGeneratedForCurrentParent < request.recordsToGenerateForCurrentParent && recordCount < maxRecordsToProcessPerRequest) {
                cases.add(createCase(contacts[parentCount]));
                recordCount = recordCount + 1;
                request.recordsGeneratedForCurrentParent = request.recordsGeneratedForCurrentParent + 1;
                request.totalRecordsGenerated = request.totalRecordsGenerated + 1;
                if (cases.size() >= maxRecordsToProcessPerInsert) {
                    insert cases;
                    publishEvent('Generated ' + request.totalRecordsGenerated + ' cases for ' + String.valueOf(request.currentParent + 1) + ' contacts.' );
                    cases.clear();
                }
            }

            // If we haven't yet inserted the maximum number of records OR we've successfully created all the required records for the CURRENT parent, then increment our counter variables.
            if (cases.size() < maxRecordsToProcessPerRequest || request.recordsGeneratedForCurrentParent >= request.recordsToGenerateForCurrentParent) {
                parentCount = parentCount + 1;
                request.currentParent = request.currentParent + 1;
            }

            // If we've generated the required number of records for the current parent, then reset the records required to generate.
            if (request.recordsGeneratedForCurrentParent >= request.recordsToGenerateForCurrentParent ) {
                request.recordsToGenerateForCurrentParent = 0;
                request.recordsGeneratedForCurrentParent = 0;
            }            
        }
        insert(cases);

        if (parentCount >= contacts.size() && request.currentParent < maxRecordsToProcessPerRequest) {
            request.maxRecordsExceeded = false;
            publishEvent('FINISH: Generated ' + request.totalRecordsGenerated + ' cases for ' + request.currentParent + ' contacts.');
        } else {
            request.maxRecordsExceeded = true;
        }

        return request;
    }

    @AuraEnabled
    public static Boolean DeleteAll() {
        Integer recordsDeleted = 0;
        Integer numberOfRecords = 0;
        Integer maxToDelete = 10000;

        // Delete Opportunities
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity LIMIT :maxToDelete];
        numberOfRecords = opportunities.size();
        recordsDeleted = recordsDeleted + numberOfRecords;
        if (numberOfRecords > 0) {
            publishEvent('Deleting ' + numberOfRecords + ' opportunities...');
            delete opportunities;
            publishEvent(numberOfRecords + ' opportunities have been deleted.');
        }

        // Delete Cases
        List<Case> cases = [SELECT Id FROM Case LIMIT :maxToDelete];
        numberOfRecords = cases.size();
        recordsDeleted = recordsDeleted + numberOfRecords;
        if (recordsDeleted > maxToDelete) {
            return false;
        }
        if (numberOfRecords > 0 && recordsDeleted < maxToDelete) {
            publishEvent('Deleting ' + numberOfRecords + ' cases...');
            delete cases;
            publishEvent(numberOfRecords + ' cases have been deleted.');
        } 

        // Delete Contacts
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT :maxToDelete];
        numberOfRecords = contacts.size();
        recordsDeleted = recordsDeleted + numberOfRecords;
        if (recordsDeleted > maxToDelete) {
            return false;
        }
        if (numberOfRecords > 0 && recordsDeleted < maxToDelete) {
            publishEvent('Deleting ' + numberOfRecords + ' contacts...');
            delete contacts;
            publishEvent(numberOfRecords + ' contacts have been deleted.');
        }

        // Delete Accounts
        List<Account> accounts = [SELECT Id FROM Account LIMIT :maxToDelete];
        numberOfRecords = accounts.size();
        recordsDeleted = recordsDeleted + numberOfRecords;
        if (recordsDeleted > maxToDelete) {
            return false;
        }        
        if (numberOfRecords > 0 && recordsDeleted < maxToDelete) {
            publishEvent('Deleting ' + numberOfRecords + ' accounts...');
            delete accounts;
            publishEvent(numberOfRecords + ' accounts have been deleted.');
        }

        publishEvent('FINISH: All records have been deleted.');

        return true;
    }

    private static Account createBusinessAccount(List<String> lastNames, List<String> addresses) {
        Account account = new Account();
        account.Industry = getRandomIndustry();
        account.Name = getRandomName(lastNames) + ' ' + getRandomCompanySuffix(account.Industry);
        // Occassionally add a company prefix to the Account Name
        if (getRandomInt(1, 4) == 1) {
            account.Name = getRandomCompanyPrefix() + ' ' + account.Name;
        }
        account.Type = getRandomString(new string[]{'Customer - Direct', 'Customer - Channel', 'Prospect', 'Channel Partner / Reseller', 'Installation Partner', 'Technology Partner', 'Other'});
        account.Rating = getRandomString(new string[]{'Hot', 'Warm', 'Warm', 'Cold'});
        account.Phone = '(555) ' + String.valueOf(getRandomInt(111, 999)) + '-' + String.valueOf(getRandomInt(1111, 9999));
        account.Fax = '(555) ' + String.valueOf(getRandomInt(111, 999)) + '-' + String.valueOf(getRandomInt(1111, 9999));
        account.AccountNumber = '000' + String.valueOf(getRandomInt(111111111, 999999999));
        Map<String, String> address = getRandomAddress(addresses);
        account.BillingStreet = address.get('street');
        account.BillingCity = address.get('city');
        account.BillingState = address.get('state');
        account.BillingPostalCode = address.get('postalcode');
        account.BillingCountry = address.get('country');
        account.ShippingStreet = address.get('street');
        account.ShippingCity = address.get('city');
        account.ShippingState = address.get('state');
        account.ShippingPostalCode = address.get('postalcode');
        account.ShippingCountry = address.get('country');
        account.NumberOfEmployees = getRandomNumberOfEmployees();
        account.AnnualRevenue = account.NumberOfEmployees * getRandomInt(20000, 200000);
        account.Ownership = getRandomString(new string[]{'Public', 'Public', 'Private', 'Private', 'Private', 'Private', 'Subsidiary', 'Subsidiary', 'Other'});
        return account;
    }

    private static Account createConsumerAccount(List<String> firstNames, List<String> lastNames, List<String> addresses) {
        Account account = new Account();
        account.Name = getRandomName(firstNames) + ' ' + getRandomName(lastNames);
        account.Type = getRandomString(new string[]{'Customer - Direct', 'Customer - Channel', 'Prospect'});
        account.Phone = '(555) ' + String.valueOf(getRandomInt(111, 999)) + '-' + String.valueOf(getRandomInt(1111, 9999));
        Map<String, String> address = getRandomAddress(addresses);
        account.BillingStreet = address.get('street');
        account.BillingCity = address.get('city');
        account.BillingState = address.get('state');
        account.BillingPostalCode = address.get('postalcode');
        account.BillingCountry = address.get('country');
        account.ShippingStreet = address.get('street');
        account.ShippingCity = address.get('city');
        account.ShippingState = address.get('state');
        account.ShippingPostalCode = address.get('postalcode');
        account.ShippingCountry = address.get('country');            
        return account;
    }

    private static Contact createContact(Account account, List<String> firstNames, List<String> lastNames, List<String> addresses) {
        Boolean isConsumerAccount = false;
        if (account.NumberOfEmployees == null) {
            isConsumerAccount = true;
        }

        Contact contact = new Contact();

        if (isConsumerAccount == true) { 
            List<String> names = account.Name.split(' ');
            contact.FirstName = names[0];
            contact.LastName = names[1];
            contact.Phone = account.Phone;
        } else {
            contact.FirstName = getRandomName(firstNames);
            contact.LastName =  getRandomName(lastNames);
            contact.Phone = '(555) ' + String.valueOf(getRandomInt(111, 999)) + '-' + String.valueOf(getRandomInt(1111, 9999));
        }
        
        contact.Email = contact.FirstName.toLowerCase() + '.' + contact.LastName.toLowerCase() + '@example.com';
        contact.AccountId = account.Id;
        contact.HomePhone = '(555) ' + String.valueOf(getRandomInt(111, 999)) + '-' + String.valueOf(getRandomInt(1111, 9999));
        contact.MobilePhone = '(555) ' + String.valueOf(getRandomInt(111, 999)) + '-' + String.valueOf(getRandomInt(1111, 9999));
        contact.MailingStreet = account.BillingStreet;
        contact.MailingCity = account.BillingCity;
        contact.MailingState = account.BillingState;
        contact.MailingPostalCode = account.BillingPostalCode;
        contact.MailingCountry = account.BillingCountry;
        contact.OtherStreet = account.BillingStreet;
        contact.OtherCity = account.BillingCity;
        contact.OtherState = account.BillingState;
        contact.OtherPostalCode = account.BillingPostalCode;
        contact.OtherCountry = account.BillingCountry;
        contact.Birthdate = getRandomBirthDate();
        contact.LeadSource = getRandomString(new string[]{'Web', 'Phone Inquiry', 'Partner Referral', 'Other'});
        contact.SSN__c = '000-' + String.valueOf(getRandomInt(11, 99)) + '-' + String.valueOf(getRandomInt(1111, 9999));
        contact.Passport_ID__c = '000' + String.valueOf(getRandomInt(111111111, 999999999));
        contact.Employee_ID__c = '000' + String.valueOf(getRandomInt(111111111, 999999999));
        contact.Member_ID__c = '000' + String.valueOf(getRandomInt(111111111, 999999999));
        return contact;
    }

    private static Case createCase(Contact contact) {
        Case myCase = new Case();
        myCase.ContactId = contact.Id;
        myCase.AccountId = contact.AccountId;
        myCase.Origin = getRandomString(new string[]{'Email', 'Phone', 'Web'});
        myCase.Priority = getRandomString(new string[]{'High', 'Medium', 'Medium', 'Medium', 'Low', 'Low'});
        myCase.Type = getRandomString(new string[]{'Billing', 'Cancellation', 'Claim', 'Enrollment', 'Support', 'Other'});
        myCase.Reason = myCase.Type;
        myCase.Status = getRandomString(new string[]{'New', 'New', 'New', 'Closed', 'Closed', 'Escalated'});
        myCase.Subject = getCaseSubject(myCase.Type);
        myCase.Description = getCaseDescription(myCase.Type);
        myCase.CreatedDate = getTrendingDateTime(Date.newInstance(2000, 1, 1), Date.newInstance(2019, 12, 31));
        return myCase;
    }

    public static Map<String, String> getRandomAddress(List<String> addresses) {
        String randomAddress = addresses[getRandomInt(0, addresses.size() - 1)].replaceAll('\r', '');
        randomAddress = addresses[getRandomInt(0, addresses.size() - 1)].replaceAll(',$', ', ');
        System.debug(randomAddress);
        String[] addressParts = randomAddress.split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
        Map<String, String> address = new Map<String, String>
        {
            'street' => addressParts[0].replaceAll('(^")|("$)',''),
            'city' => addressParts[1],
            'state' => addressParts[2],
            'country' => addressParts[3],
            'postalcode' => addressParts[4]
        };
        return address;
    }

    public static Date getRandomBirthdate() {
        return getRandomDate(Date.newInstance(1940, 1, 1), Date.newInstance(2005, 31, 12));
    }

    private static Integer getRandomInt(Integer lowerLimit, Integer upperLimit){
        Integer rand = Math.round(Math.random() * (upperLimit - lowerLimit)) + lowerLimit;
        return rand;
    }

    private static Boolean getRandomBoolean() {
        if (getRandomInt(0,1) == 0) {
            return false;
        } else {
            return true;
        }
    }

    private static String getRandomString(string[] Strings) {
        return Strings[getRandomInt(0, Strings.size()-1)];
    }

    private static Date getRandomDate(Date minDate, Date maxDate) {
        return getRandomDateTime(minDate, maxDate).date();
    }

    private static DateTime getRandomDateTime(Date minDate, Date maxDate) {
        Integer rangeSize = minDate.daysBetween(maxDate) + 1;
        Decimal daysToAdd = rangeSize * math.Random();
        DateTime result = DateTime.newInstance(
            minDate.year(),
            minDate.month(),
            minDate.day(),
            getRandomInt(6, 19),
            getRandomInt(0, 59),
            getRandomInt(0, 59)
        );
        result = result.addDays(daysToAdd.intValue());
        return result;
    }
    
    private static DateTime getTrendingDateTime(Date minDate, Date maxDate) {
        DateTime result = getRandomDateTime(minDate, maxDate);
        System.debug('getTrendingDateTime Original: ' + result.format());
        Integer rangeSize = result.date().daysBetween(maxDate) + 1;
        result = result.addDays(getRandomInt(0, rangeSize));
        System.debug('getTrendingDateTime Trending: ' + result.format());
        return result;
    }

    private static String getRandomName(List<String> names) {
        return names[getRandomInt(0, names.size() - 1)].replaceAll('\r', '');
    }

    private static String getRandomIndustry() {
        return getRandomString(new string[] {
            'Agriculture',
            'Apparel',
            'Banking',
            'Biotechnology',
            'Chemicals',
            'Communications',
            'Construction',
            'Consulting',
            'Education',
            'Electronics',
            'Energy',
            'Engineering',
            'Entertainment',
            'Environmental',
            'Finance',
            'Food & Beverage',
            'Government',
            'Healthcare',
            'Hospitality',
            'Insurance',
            'Machinery',
            'Manufacturing',
            'Media',
            'Not For Profit',
            'Recreation',
            'Retail',
            'Shipping',
            'Technology',
            'Telecommunications',
            'Transportation',
            'Utilities',
            'Other'
        });
    }
 
    private static String getRandomCompanyPrefix() {
        return getRandomString(new string[] {
            'Premier',
            'Global',
            'National',
            'Regional',
            'First'
        });
    }

    private static String getRandomCompanySuffix(string companySuffix) {
        switch on companySuffix {
            when 'Agriculture' {
                companySuffix = getRandomString(new string[] {
                    'Agriculture',
                    'Farms'
                });
            }
            when 'Apparel' {
                companySuffix = getRandomString(new string[] {
                    'Apparel',
                    'Clothing'
                });
            }
            when 'Banking' {
                companySuffix = getRandomString(new string[] {
                    'Bank',
                    'Financial',
                    'Investing',
                    'Investments'
                });
            }
            when 'Biotechnology' {
                companySuffix = getRandomString(new string[] {
                    'Biotechnology',
                    'Labs',
                    'Research'
                });
            }             
            when 'Not For Profit' {
                companySuffix = getRandomString(new string[] {
                    'Foundation',
                    'Organization'
                });
            }
            when 'Other' {
                companySuffix = getRandomString(new string[] {
                    'Industries',
                    'Partners',
                    'Corp',
                    'Ltd',
                    'Affiliates'
                });
            }
        }
        return companySuffix;
    }

    private static String getCaseSubject(string caseType) {
        switch on caseType {
            when 'Billing' {
                String word = getRandomString(new string[] {
                    'bill',
                    'invoice',
                    'service',
                    'policy',
                    'order',
                    'contract',
                    'subscription'
                });
                return getRandomString(new string[] {
                    'Questions about my ' + word,
                    'My ' + word,
                    word.capitalize() + ' question',
                    'Need help with my ' + word
                });
            }
            when 'Cancellation' {
                String word = getRandomString(new string[] {
                    'order',
                    'subscription',
                    'contract',
                    'service',
                    'policy'
                });                
                return getRandomString(new string[] {
                    word.capitalize() + ' cancellation',
                    'Cancel my ' + word,
                    'Please cancel my ' + word,
                    'Need to cancel my ' + word
                });
            }
            when 'Claim' {
                return getRandomString(new string[] {
                    'Question about my claim',
                    'Status of claim',
                    'Need copy of my claim'
                });
            }
            when 'Enrollment' {
                return getRandomString(new string[] {
                    'Enrollment dates',
                    'Need to enroll',
                    'Status of enrollment',
                    'Enrollment question',
                    'Question about enrollment process'
                });
            }
            when 'Support' {
                return getRandomString(new string[] {
                    'Setup question',
                    'Need help with configuration',
                    'Setup problem',
                    'Warranty question',
                    'Schedule warranty service',
                    'Question about message'
                });
            }
            when else {
                return getRandomString(new string[] {
                    'Transfer service',
                    'Need assistance',
                    'General question',
                    'Can\'t find information',
                    'Please contact me'
                });
            }
        }
    }

    private static String getCaseDescription(string caseType) {
        switch on caseType {
            when 'Billing' {
                return 'I have a billing question related to my account.';
            }
            when 'Cancellation' {
                return 'I need to cancel our account.';
            }
            when 'Claim' {
                return 'I have claims question related to my account.';
            }
            when 'Enrollment' {
                return 'I have an enrollment question related to my account..';
            }
            when 'Support' {
                return 'I have a service question and would like some assistance.';
            }
            when else {
                return 'I need some general assistance related to our account.';
            }
        }
    }

    public static Integer getRandomNumberOfEmployees() {
        Integer numberOfEmployees = getRandomInt(0, 99);
        Integer numberOfZeros = getRandomInt(0, 4);

        // Bias towards smaller companies
        if (numberOfZeros > 1) {
            numberOfZeros = getRandomInt(0, 4);
        }
        if (numberOfZeros > 2) {
            numberOfZeros = getRandomInt(0, 4);
        }

        if (numberOfZeros > 0) {
            numberOfEmployees = numberOfEmployees * Math.pow(10, numberOfZeros).intValue();
        }

        return numberOfEmployees;
    }

    private static List<String> getFirstNames() {
        StaticResource sr = [SELECT id,body FROM StaticResource WHERE Name = 'first_names'];
        List<String> allNames = sr.body.toString().split('\n');
        return allNames;
    }

    private static List<String> getLastNames() {
        StaticResource sr = [SELECT id,body FROM StaticResource WHERE Name = 'last_names'];
        List<String> allNames = sr.body.toString().split('\n');
        return allNames;
    }

    private static List<String> getAddresses() {
        StaticResource sr = [SELECT id,body FROM StaticResource WHERE Name = 'addresses'];
        List<String> allAddresses = sr.body.toString().split('\n');
        return allAddresses;
    }

    private static List<String> getCompanyPrefixes() {
        StaticResource sr = [SELECT id,body FROM StaticResource WHERE Name = 'company_prefixes'];
        List<String> companyPrefixes = sr.body.toString().split('\n');
        return companyPrefixes;
    }

    private static List<String> getCompanySuffixes() {
        StaticResource sr = [SELECT id,body FROM StaticResource WHERE Name = 'company_suffixes'];
        List<String> companySuffixes = sr.body.toString().split('\n');
        return companySuffixes;
    }

    private static void publishEvent(String message) {
        Data_Generator_Event__e event = new Data_Generator_Event__e();
        event.Message__c = message;
        Database.SaveResult result = EventBus.publish(event);
        if (result.isSuccess()) {
            System.debug('Successfully published event.');
        }
    }

    private static Integer maxRecordsToProcessPerRequest {
        get { return 1000; }
    }

    private static Integer maxRecordsToProcessPerInsert {
        get { return 100; }
    }   
}