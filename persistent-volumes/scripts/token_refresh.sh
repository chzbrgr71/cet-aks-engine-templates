#!/bin/bash
# This script packages the application chart and pushes it to the ACR. It has to be executed after pushing the docker images with the build_and_push_image.sh script

. ../../cluster/environment/aks_info.sh

if [ ! -x "../../cluster/environment/aks_info.sh" ]; then
    echo "No aks_info.sh file with resource information, you have to create it manually and give it execution permissions; there's a template meant as a starter file."
    exit 1;
fi

helm repo remove $AZURE_CONTAINER_REGISTRY_INGRESS

# Add the ACR as a Helm repository to install packages
az acr helm repo add --name $AZURE_CONTAINER_REGISTRY_INGRESS

# Login to the Azure Container Registry (ACR)
az acr login --name $AZURE_CONTAINER_REGISTRY_INGRESS
