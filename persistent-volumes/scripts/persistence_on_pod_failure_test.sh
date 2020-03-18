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
NODE=`echo $POD_OBJECT | awk '{print $7}'`

printf "\n\e[1;34m%-6s\e[m\n" "Getting resources details"
kubectl get pods -l app=mysql --output wide

printf "\n\e[1;34m%-6s\e[m\n" "The pod '$POD_NAME' is now running on the node '$NODE'"

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

# Delete the pod that contains the MySQL instance
printf "\n\e[1;34m%-6s\e[m\n" "Deleting $POD_NAME pod"
kubectl delete pod ${POD_NAME}

# Timeout to ensure the container has time to be is brought up again
sleep 5

# Get the pod where the MySQL instance exists
NEW_POD_OBJECT=`kubectl get pods -l app=mysql --output wide | grep -v NAME`
NEW_POD_NAME=`echo $NEW_POD_OBJECT | awk '{print $1}'`
NEW_NODE=`echo $NEW_POD_OBJECT | awk '{print $7}'`

printf "\n\e[1;34m%-6s\e[m\n" "Getting resources details"
kubectl get pods -l app=mysql --output wide

# Check that the table exists in the pod running MySQL
printf "\n\e[1;34m%-6s\e[m\n" "Checking database values on $NEW_POD_NAME pod"
kubectl exec -it pod/$NEW_POD_NAME \
             -- mysql -u "root" -p"root" \
             --execute "USE demo; DESCRIBE counter; SELECT * FROM counter;"
