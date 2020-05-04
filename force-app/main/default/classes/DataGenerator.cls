public with sharing class DataGenerator {
    @AuraEnabled
    public static void generateAccounts(String accountType, Integer numberToGenerate) {
        publishEvent('Generating ' + numberToGenerate + ' account records...');

        List<String> firstNames = getFirstNames();
        List<String> lastNames = getLastNames();
        List<String> addresses = getAddresses();
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < numberToGenerate; i++) {
            switch on accountType {
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

            if (accounts.size() >= 100) {
                insert accounts;
                publishEvent('Generated ' + String.valueOf(i+1) + ' of ' + numberToGenerate + ' accounts.');
                accounts.clear();

            }
        }

        insert accounts;        
        publishEvent('JOB FINISHED: ' + numberToGenerate + ' accounts were generated.');
    }

    @AuraEnabled
    public static void generateContactsForAccounts(Integer minimumToGenerate, Integer maximumToGenerate) {
        publishEvent('Generating ' + minimumToGenerate + '-' + maximumToGenerate + ' contact records per account...');

        List<String> firstNames = getFirstNames();
        List<String> lastNames = getLastNames();
        List<String> addresses = getAddresses();
        List<Account> accounts = [SELECT Id, Name, Phone, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, NumberOfEmployees  FROM Account];
        List<Contact> contacts = new List<Contact>();

        for (Integer accountCount = 0; accountCount < accounts.size(); accountCount++) {
            Integer numberToGenerate = getRandomInt(minimumToGenerate, maximumToGenerate);
            for (Integer contactCount = 0; contactCount < numberToGenerate; contactCount++) {
                contacts.add(createContact(accounts[accountCount], firstNames, lastNames, addresses));
                if (contacts.size() >= 100) {
                    insert contacts;
                    publishEvent('Processed ' + String.valueOf(accountCount+1) + ' of ' + accounts.size() + ' accounts.');
                    contacts.clear();
                }
            }
        }

        insert(contacts);
        publishEvent('JOB FINISHED: ' + minimumToGenerate + '-' + maximumToGenerate + ' contact records were generated for ' + accounts.size() + ' accounts.');
    }

    @AuraEnabled
    public static List<Case> GenerateCasesForContacts(List<Account> contacts, Integer minimumToGenerate, Integer maximumToGenerate) {
        List<Case> cases = new List<Case>();
        return cases;
    }

    @AuraEnabled
    public static void DeleteAll() {
        publishEvent('Deleting ALL records...');

        List<Account> accounts = [SELECT Id FROM Account];
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Case> cases = [SELECT Id FROM Case];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
        
        delete cases;
        delete opportunities;
        delete contacts;
        delete accounts;

        publishEvent('JOB FINISHED: All records have been deleted.');
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

    private static Date getRandomDate(Date min, Date max) {
        // Convert to DateTime values
        DateTime mint = min, maxt = max.addDays(1);
        // Then convert to milliseconds since Jan 1, 1970, and get difference in ms
        Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
        // Return a date between minms and maxms.
        return DateTime.newInstance(
            minms + Math.mod(Math.abs(Crypto.getRandomLong()), diff)
        ).date();
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
                return 'Question about my bill';
            }
            when 'Cancellation' {
                return 'Cancel my service';
            }
            when 'Claim' {
                return 'File a new claim';
            }
            when 'Encrollment' {
                return 'Enroll for service';
            }
            when 'Support' {
                return 'Problems using service';
            }
            when else {
                return 'Transfer service';
            }
        }
    }

    private static String getCaseDescription(string caseType) {
        switch on caseType {
            when 'Billing' {
                return 'I received my latest billing invoice and have questions about 1 of the line items.';
            }
            when 'Cancellation' {
                return 'I\'m moving and will no longer need my service and need assistant to cancel.';
            }
            when 'Claim' {
                return 'I\'d like to file a new claim and have some questions about the information required.';
            }
            when 'Encrollment' {
                return 'I need to enroll for service and would like to activate next week.';
            }
            when 'Support' {
                return 'I\'m having difficult using the service and would like some assistant.';
            }
            when else {
                return 'I need help transferring my service to another account.';
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
}
