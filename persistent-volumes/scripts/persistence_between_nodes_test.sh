#!/bin/bash
. ../../cluster/environment/aks_info.sh

# Exit immediately when a command fails
# Only exit with zero if all commands of the pipeline exit successfully
set -euo pipefail

if [ ! -x "../../cluster/environment/aks_info.sh" ]; then
    echo "No aks_info.sh file with resource information, you have to create it manually and give it execution permissions; there's a template meant as a starter file."
    exit 1;
fi

# Login to the Azure Container Registry (ACR)
az acr login --name $AZURE_CONTAINER_REGISTRY_PV

# Get the pod where the MySQL instance exists
POD_OBJECT=`kubectl get pods -l app=mysql --output wide | grep -v NAME`
POD_NAME=`echo $POD_OBJECT | awk '{print $1}'`
INIT_NODE=`echo $POD_OBJECT | awk '{print $7}'`

printf "\n\e[1;34m%-6s\e[m\n" "Getting resources details"
kubectl get pods -l app=mysql --output wide

printf "\n\e[1;34m%-6s\e[m\n" "The pod '$POD_NAME' is running on the node '$INIT_NODE'"

# Check that the table exists in the pod running MySQL
printf "\n\e[1;34m%-6s\e[m\n" "Checking database values on $POD_NAME pod"
kubectl exec -it pod/$POD_NAME \
             -- mysql -u "root" -p"root" \
             --execute "USE demo; DESCRIBE counter; SELECT * FROM counter;"

# Modify a value
printf "\n\e[1;34m%-6s\e[m\n" "Modifying the dummy data on the database"
kubectl exec -it pod/$POD_NAME \
             -- mysql -u "root" -p"root" \
             --execute "USE demo; UPDATE counter SET counter_val = counter_val + 1; SELECT * FROM counter;"

# Mark the node where the pod currently is as unschedulable
printf "\n\e[1;34m%-6s\e[m\n" "Setting $INIT_NODE node as unschedulable"
kubectl cordon ${INIT_NODE}

# Delete the pod that contains the MySQL instance
printf "\n\e[1;34m%-6s\e[m\n" "Deleting $POD_NAME pod"
kubectl delete pod ${POD_NAME}

printf "\n\e[1;34m%-6s\e[m\n" "Waiting 30 seconds for the deployment to create the pod on the next available node"
sleep 30

# Verify that a new pod has been created and scheduled in a different node
printf "\n\e[1;34m%-6s\e[m\n" "Getting new created resources details"
kubectl get pods -l app=mysql --output wide

# Get the pod where the MySQL instance exists
POD_OBJECT=`kubectl get pods -l app=mysql --output wide | grep -v NAME`
POD_NAME=`echo $POD_OBJECT | awk '{print $1}'`
SEC_NODE=`echo $POD_OBJECT | awk '{print $7}'`

printf "\n\e[1;34m%-6s\e[m\n" "The pod '$POD_NAME' is now running on the node '$SEC_NODE'"

# Check that the table exists in the pod running MySQL
printf "\n\e[1;34m%-6s\e[m\n" "Checking database values on $POD_NAME pod"
kubectl exec -it pod/$POD_NAME \
             -- mysql -u "root" -p"root" \
             --execute "USE demo; DESCRIBE counter; SELECT * FROM counter;"

# Resume scheduling new pods onto the node previously unavailable node
printf "\n\e[1;34m%-6s\e[m\n" "Setting $INIT_NODE node as schedulable.."
kubectl uncordon ${INIT_NODE}
