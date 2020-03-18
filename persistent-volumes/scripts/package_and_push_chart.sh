#!/bin/bash
# This script packages the application chart and pushes it to the ACR; it has to be executed after setting up the kubernetes environment

. ../../cluster/environment/aks_info.sh

# Exit immediately when a command fails
# Only exit with zero if all commands of the pipeline exit successfully
set -xeuo pipefail

if [ ! -x "../../cluster/environment/aks_info.sh" ]; then
    echo "No aks_info.sh file with resource information, you have to create it manually and give it execution permissions; there's a template meant as a starter file."
    exit 1;
fi

# Re-login to the Azure Container Registry (ACR) in case it is needed
az acr login --name $AZURE_CONTAINER_REGISTRY_PV

# Helm variables
CHART=pvdemo
VERSION=1.0.0

# Package the charts
helm package ../chart -d ../chart_packages

# Push the charts to the ACR
az acr helm push --force "../chart_packages/$CHART-$VERSION.tgz" \
                 --name $AZURE_CONTAINER_REGISTRY_PV

# Update the local Helm repository cache so we can install the chart
helm repo update
