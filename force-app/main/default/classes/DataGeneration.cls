public with sharing class DataGeneration {
    @AuraEnabled
    public static void GenerateAccount() {
        GenerateAccounts(1, false);
    }

    @AuraEnabled
    public static void GenerateAccounts(Integer NumberofAccounts) {
        GenerateAccounts(NumberofAccounts, false);      
    }

    @AuraEnabled
    public static void DeleteAll() {
        List<Account> accounts = [SELECT Id FROM Account];
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Case> cases = [SELECT Id FROM Case];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
        
        delete cases;
        delete opportunities;
        delete contacts;
        delete accounts;
    }

    private static void generateAccounts(Integer NumberofAccounts, Boolean IsPredictionSample) {
        List<String> FirstNames = getFirstNames();
        List<String> LastNames = getLastNames();

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < NumberofAccounts; i++) {
            accounts.add(CreateAccount(getRandomName(FirstNames) + ' ' + getRandomName(LastNames)));
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for (Account account : accounts) {
            contacts.add(CreateContact(account));
        }
        insert contacts;

        List<Case> cases = new List<Case>();
        for (Contact contact : contacts) {
            cases.add(createCase(contact));
        }
        insert cases;        
    }

    private static Account createAccount(String name) {
        Account account = new Account();
        account.Name = name;
        account.Type = 'Customer';
        account.Phone = '(555) ' + String.valueOf(getRandomInt(111, 999)) + '-' + String.valueOf(getRandomInt(1111, 9999));
        account = getRandomAddress(account);
        return account;
    }

    private static Contact createContact(Account account) {
        Contact contact = new Contact();
        List<String> names = account.Name.split(' ');
        contact.FirstName = names[0];
        contact.LastName = names[1];
        contact.Email = contact.FirstName.toLowerCase() + '.' + contact.LastName.toLowerCase() + '@example.com';
        contact.AccountId = account.Id;
        contact.Phone = account.Phone;
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

    public static Account getRandomAddress(Account account) {
        List<Map<String, String>> addresses = new List<Map<String, String>>();
        addresses.add(addAddress('950 East Paces Ferry Road NE', 'Atlanta', 'GA', '30326', 'USA'));
        addresses.add(addAddress('929 108th Ave NE', 'Bellevue', 'WA', '98004', 'USA'));
        addresses.add(addAddress('500 Boylston Street', 'Boston', 'MA', '02116', 'USA'));
        addresses.add(addAddress('111 West Illinois Street', 'Chicago', 'IL', '60654', 'USA'));
        addresses.add(addAddress('2550 Wasser Terrace', 'Herndon', 'VA', '20171', 'USA'));
        addresses.add(addAddress('2035 NE Cornelius Pass Road', 'Hillsboro', 'OR', '97124', 'USA'));
        addresses.add(addAddress('111 Monument Circle', 'Indianapolis', 'IN', '46204', 'USA'));
        addresses.add(addAddress('300 Spectrum Center Drive', 'Irvine', 'CA', '92618', 'USA'));
        addresses.add(addAddress('361 Centennial Parkway', 'Louisville', 'CO', '80027', 'USA'));
        addresses.add(addAddress('1095 Avenue of the Americas', 'New York', 'NY', '10036', 'USA'));
        addresses.add(addAddress('1442 2nd Street', 'Santa Monica', 'CA', '90401', 'USA'));
        addresses.add(addAddress('12825 East Mirabeau Parkway', 'Spokane', 'WA', '99216', 'USA'));
        addresses.add(addAddress('4301 West Boy Scout Blvd', 'Tampa', 'FL', '33607', 'USA'));
        addresses.add(addAddress('10 Bay Street', 'Toronto', 'ON', 'M5J 2R8', 'Canada'));
        addresses.add(addAddress('900 Bulldog Run', 'Rolla', 'MO', '65401', 'USA'));
        addresses.add(addAddress('818 Sparta Hwy', 'Milledgeville', 'GA', '31061', 'USA'));
        addresses.add(addAddress('1541 E 4th St', 'Casper', 'WY', '82601', 'USA'));
        addresses.add(addAddress('2012 Northern Plains Dr', 'Bismarck', 'ND', '58504', 'USA'));
        addresses.add(addAddress('22655 Fairfield Rd', 'St Augusta', 'MN', '56301', 'USA'));
        addresses.add(addAddress('206 De Korra Ln', 'Wisconsin Dells', 'WI', '53965', 'USA'));
        addresses.add(addAddress('1012 Grand River Dr NE', 'Ada', 'MI', '49301', 'USA'));
        addresses.add(addAddress('400 Grant Ave', 'Duquesne', 'PA', '15110', 'USA'));
        addresses.add(addAddress('551 Oakdale Rd', 'Jamestown', 'NC', '27282', 'USA'));
        addresses.add(addAddress('4561 Springdale Rd', 'Millbrook', 'AL', '36054', 'USA'));
        addresses.add(addAddress('22750 N May Ave', 'Edmond', 'OK', '73025', 'USA'));
        addresses.add(addAddress('7139 Kilback Mountains', 'Antonito', 'CO', '81120', 'USA'));
        addresses.add(addAddress('175 Dunlap Road', 'Craigmont', 'ID', '83523', 'USA'));
        addresses.add(addAddress('174 Unnamed Road', 'Youngstown', 'FL', '32466', 'USA'));
        addresses.add(addAddress('84 Ocean Drive', 'Forest Home', 'AL', '36030', 'USA'));
        addresses.add(addAddress('87 Arizona 87', 'Coolidge', 'AZ', '85128', 'USA'));
        addresses.add(addAddress('8629 238th Road', 'Nortonville', 'KS', '66060', 'USA'));
        addresses.add(addAddress('7926 Droege Road', 'Decatur', 'IN', '46733', 'USA'));
        addresses.add(addAddress('7452 30th Avenue Northeast', 'Willow City', 'ND', '58384', 'USA'));
        addresses.add(addAddress('145 County Road 88', 'Guffey', 'CO', '80820', 'USA'));
        addresses.add(addAddress('3392 North Huron Road', 'Tawas City', 'MI', '48763', 'USA'));
        addresses.add(addAddress('14878 Lost River Court', 'Hughesville', 'MD', '20637', 'USA'));
        addresses.add(addAddress('2084 Waelchi Road', 'Denton', 'MT', '59430', 'USA'));
        addresses.add(addAddress('77820 Vineyard Canyon Road', 'San Miguel', 'CA', '93451', 'USA'));
        addresses.add(addAddress('542 Candido Hills', 'Miles City', 'MT', '59301', 'USA'));
        addresses.add(addAddress('23 Browns Lake Road', 'Helmville', 'MT', '59843', 'USA'));
        addresses.add(addAddress('5167 Pauline Field', 'Challis', 'ID', '83226', 'USA'));
        addresses.add(addAddress('30208 Lookout Road', 'Paola', 'KS', '66071', 'USA'));
        addresses.add(addAddress('301 Sherman Street', 'Huntington', 'IN', '46750', 'USA'));
        addresses.add(addAddress('620 N Westmoreland Rd', 'DeSoto', 'TX', '75115', 'USA'));
        addresses.add(addAddress('307 Bentley Manor', 'Shavano Park', 'TX', '78249', 'USA'));
        addresses.add(addAddress('6010 London Dr', 'Sunset Valley', 'TX', '78745', 'USA'));
        addresses.add(addAddress('10105 Propps St NE', 'Albuquerque', 'NM', '87112', 'USA'));
        addresses.add(addAddress('112 N El Rancho Rd', 'Santa Fe', 'NM', '87501', 'USA'));
        addresses.add(addAddress('1335 Madison St NE', 'Salem', 'OR', '97301', 'USA'));
        addresses.add(addAddress('6 Morningview Cir', 'Lake Oswego', 'OR', '97035', 'USA'));
        addresses.add(addAddress('541 SW Georgetown Way', 'Beaverton', 'OR', '97006', 'USA'));
        addresses.add(addAddress('30303 SE Lusted Rd', 'Gresham', 'OR', '97080', 'USA'));
        addresses.add(addAddress('3604 84th St E', 'Tacoma', 'WA', '98446', 'USA'));
        addresses.add(addAddress('658 Gibraltar Ct', 'Milpitas', 'CA', '95035', 'USA'));
        addresses.add(addAddress('4766 E Whitmore Ave', 'Ceres', 'CA', '95307', 'USA'));

        Map<String, String> address = addresses[getRandomInt(0, addresses.size() - 1)];

        account.BillingStreet = address.get('street');
        account.BillingCity = address.get('city');
        account.BillingState = address.get('state');
        account.BillingPostalCode = address.get('postcode');
        account.BillingCountry = address.get('country');
        account.ShippingStreet = address.get('street');
        account.ShippingCity = address.get('city');
        account.ShippingState = address.get('state');
        account.ShippingPostalCode = address.get('postcode');
        account.ShippingCountry = address.get('country');

        return account;
    }

    private static Map<String, String> addAddress(String street, String city, String state, String postcode, String country) {
        return new Map<String, String>{'street' => street, 'city' => city, 'state' => state, 'postcode' => postcode, 'country' => country};
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

}