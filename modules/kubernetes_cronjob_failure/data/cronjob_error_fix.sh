

#!/bin/bash



# Set the namespace and cronjob name

NAMESPACE=${NAMESPACE}

CRONJOB=${CRONJOB_NAME}



# Check for "100 missed start times" error

if kubectl get cronjob $CRONJOB -n $NAMESPACE | grep -q "100 missed"; then

  # Delete the cronjob

  kubectl delete cronjob $CRONJOB -n $NAMESPACE

  

  # Recreate the cronjob

  kubectl apply -f ${PATH_TO_CRONJOB_YAML} -n $NAMESPACE

  

  # Verify the new cronjob is scheduled and running

  kubectl get cronjob $CRONJOB -n $NAMESPACE

  kubectl get pods -l job-name=$CRONJOB -n $NAMESPACE

fi