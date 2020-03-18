#!/bin/bash
# This script installs or upgrades the application's chart in the Kubernetes cluster. It has to be executed after pushing the helm charts

. ../../cluster/environment/aks_info.sh

if [ ! -x "../../cluster/environment/aks_info.sh" ]; then
    echo "No aks_info.sh file with resourcs information, you have to create it manually and give it execution permissions."
    exit 1;
fi

# Helm variables
CHART=pvdemo
RELEASE=$CHART
VERSION=1.0.0

# Install it on the cluster.
if helm status "${RELEASE}" &>/dev/null; then
  helm upgrade \
    "$RELEASE" \
    $AZURE_CONTAINER_REGISTRY_PV/$CHART
else
  helm install \
    "$RELEASE" \
    $AZURE_CONTAINER_REGISTRY_PV/$CHART
fi
