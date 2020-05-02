({
    generateAccounts : function(component, helper, accountsGenerated, accountsRequested) {
        var numberToGenerate = accountsRequested - accountsGenerated;
        if (numberToGenerate > 100) {
            numberToGenerate = 100;
        }

        var action = component.get("c.GenerateAccounts");
        action.setParams({ NumberofAccounts : numberToGenerate });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                accountsGenerated = accountsGenerated + numberToGenerate;
                helper.addToLog(component, "Generated " + accountsGenerated + " of " + accountsRequested + " accounts.");
                if (accountsGenerated < accountsRequested) {
                    helper.generateAccounts(component, helper, accountsGenerated, accountsRequested);
                }
            }
            else if (state === "INCOMPLETE") {
                helper.addToLog("Status: Incomplete");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.addToLog("Error: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);

        
    },

    showSuccess : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            type: 'success'
        });
        toastEvent.fire();        
    },

    addToLog :  function(component, message) {
        var newDate = new Date(Date.now()); 
        var dateString = newDate.toUTCString();
                
        var log = component.get("v.log");
        log = dateString + " - " + message + "\n" + log;
        component.set("v.log", log);
        console.log(message);
    }
})