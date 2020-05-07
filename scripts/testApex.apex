// sfdx force:apex:execute -f ./scripts/testApex.apex 
// Boolean result = DataGenerator.getRandomBooleanByPercentChance(-50);

System.debug('today: ' + Date.today().addDays(-1).format());
Date myDate = Date.newInstance(2020, 4, 1);
String status = DataGenerator.getCaseStatus(myDate);
System.debug('status: ' + status);