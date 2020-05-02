({
    resetAccounts : function(component, event, helper) {
        helper.addToLog(component, "Resetting accounts... (be patient)");
        var action = component.get("c.DeleteAll");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.addToLog(component, "All accounts and activities have been deleted.");
            }
            else if (state === "INCOMPLETE") {
                helper.addToLog(component, "Status:Incomplete. Something unexpected happened.");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.addToLog(component, "Error: " + errors[0].message);
                    }
                } else {
                    helper.addToLog(component, "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    createAccounts: function(component, event, helper) {
        var accountsRequested = component.get("v.numberOfAccounts");
        helper.addToLog(component, "Generating accounts... (be patient)");
        helper.generateAccounts(component, helper, 0, accountsRequested);
    }
})