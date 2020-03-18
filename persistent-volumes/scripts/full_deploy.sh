#!/bin/bash
# This script packages and pushes helm charts and then installs them.
# It has to be executed after setting the Kubernetes environment with the kubernetes_setup.sh script

# Exit immediately when a command fails
# Only exit with zero if all commands of the pipeline exit successfully
set -euo pipefail

./package_and_push_chart.sh
./deploy.sh

echo "Waiting 2 minutes for the database to be ready to populate it with dummy data"
sleep 120

./populate_mysql_on_deploy.sh
