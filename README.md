
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Cronjob Failure
---

A Kubernetes Cronjob Failure incident occurs when a scheduled task, or cronjob, in a Kubernetes cluster fails to execute as expected. This may be due to a variety of reasons, such as misconfiguration, resource constraints, or software bugs. The incident requires investigation and debugging to identify the root cause of the failure and resolve the issue to restore normal operation.

There is also a kubernetes limitation that permanently stops a cronjob after too many (e.g. 100) execution errors or failures to schedule.

### Parameters
```shell
export CRONJOB_NAME="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export EXPECTED_SCHEDULE="PLACEHOLDER"

export PATH_TO_CRONJOB_YAML="PLACEHOLDER"
```

## Debug

### Check if the cronjob is still active
```shell
kubectl get cronjobs
```

### Check if the pods created by the cronjob are still running
```shell
kubectl get pods -l job-name=${CRONJOB_NAME}
```

### Check the logs of the pods created by the cronjob
```shell
kubectl logs ${POD_NAME}
```

### Check if the cronjob schedule is correct
```shell
kubectl describe cronjobs/${CRONJOB_NAME}
```

### Check if there are any errors in the cronjob events
```shell
kubectl describe events --field-selector involvedObject.name=${CRONJOB_NAME}
```

### Check if the cronjob image exists in the container registry
```shell
kubectl describe cronjobs/${CRONJOB_NAME} | grep Image:
```

### Check the status of the last cronjob run
```shell
kubectl describe cronjobs/${CRONJOB_NAME} | grep Last Schedule Time:
```

### Check if the cronjob is running on the expected node
```shell
kubectl describe pods ${POD_NAME} | grep Node:
```

### Check if the pod has sufficient resources
```shell
kubectl describe pods ${POD_NAME} | grep -i resource
```

### Check if there are any errors in the pod events
```shell
kubectl describe pods ${POD_NAME} | grep -i events
```

## Repair

### Check the cronjob configuration to ensure that it is correctly defined and scheduled to run at the intended time.
```shell


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


```

### Check for "100 missed start times" error. Recreate the cronjob if found.
```shell


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


```