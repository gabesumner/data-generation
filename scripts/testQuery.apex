// sfdx force:apex:execute -f ./scripts/testQuery.apex 
List<Account> accounts = [SELECT Id, Name FROM Account OFFSET 100 ];
Integer count = 0;
for (Account account : accounts) {
    count = count + 1;
    System.System.debug(count + ': ' + account.Id + ' - ' + account.Name);
}