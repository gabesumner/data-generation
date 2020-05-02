# Create the org
sfdx force:org:create -f config/project-scratch-def.json --setalias data-generator --setdefaultusername

# Push the metadata into the new scratch org.
sfdx force:source:push

# Assign user the permset
sfdx force:user:permset:assign -n DataGenerator

# Set the default password.
sfdx shane:user:password:set -g User -l User -p salesforce1

# Open the org.
sfdx force:org:open