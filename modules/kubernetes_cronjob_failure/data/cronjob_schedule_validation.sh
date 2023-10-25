

#!/bin/bash



# Set the namespace and cronjob name

NAMESPACE=${NAMESPACE}

CRONJOB_NAME=${CRONJOB_NAME}



# Get the cronjob object

CRONJOB=$(kubectl get cronjob $CRONJOB_NAME -n $NAMESPACE -o json)



# Check if the cronjob schedule is correct

EXPECTED_SCHEDULE=${EXPECTED_SCHEDULE}

CURRENT_SCHEDULE=$(echo $CRONJOB | jq -r .spec.schedule)



if [ "$CURRENT_SCHEDULE" != "$EXPECTED_SCHEDULE" ]; then

    # Update the cronjob schedule

    kubectl patch cronjob $CRONJOB_NAME -n $NAMESPACE --type='json' -p='[{"op": "replace", "path": "/spec/schedule", "value": "'"$EXPECTED_SCHEDULE"'"}]'

fi