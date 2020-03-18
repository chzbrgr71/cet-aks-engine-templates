#!/bin/bash
. ../../cluster/environment/aks_info.sh

# Exit immediately when a command fails
# Only exit with zero if all commands of the pipeline exit successfully
set -euo pipefail

if [ ! -x "../../cluster/environment/aks_info.sh" ]; then
    echo "No aks_info.sh file with resource information, you have to create it manually and give it execution permissions; there's a template meant as a starter file."
    exit 1;
fi

# Get pod running MySQL instance and extract the name and status
POD_OBJECT=`kubectl get pods -l app=mysql --output wide | grep Running | grep 1/1`
POD_NAME=`echo $POD_OBJECT | awk '{print $1}'`
POD_STATUS=`echo $POD_OBJECT | awk '{print $3}'`

if [[ $POD_STATUS == 'Running' ]]; then

    # Create database and table with counter for demo
    printf "\n\e[1;34m%-6s\e[m\n" "Creating database"
    kubectl exec -it $POD_NAME -- mysql -u "root" -p"root" --execute "CREATE DATABASE demo; USE demo; CREATE TABLE counter ( id INT NOT NULL AUTO_INCREMENT, counter_val INT(3) NOT NULL DEFAULT 0, PRIMARY KEY (id) ); INSERT INTO counter (counter_val) VALUES (1);"

    # Checking database
    printf "\n\e[1;34m%-6s\e[m\n" "Retieving database values inserted"
    kubectl exec -it $POD_NAME \
                -- mysql -u "root" -p"root" \
                --execute "USE demo; DESCRIBE counter; SELECT * FROM counter;"

else
    echo "Waiting 40 seconds for the pod running MySQL to be ready before trying to populate it again"
    sleep 40
fi
