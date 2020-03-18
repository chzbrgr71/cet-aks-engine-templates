# Persistent Volume Proof of Concept

This spike pushes a deployment with an instance of MySQL to a Kubernetes cluster. The database persists data by mounting a volume using AzureFile storage with a PersistentVolumeClaim.

## In order to execute this spike

In the environment folder:

1. Create the aks_info.sh and credentials.sh files with the necessary values; there is a template for each of the files.

In the scripts folder:

2. Execute kubernetes_setup.sh to create the resource group and set up the Kubernetes environment. Note that there is an environment variable in aks_info.sh called "IS_MANAGED_CLUSTER" that selects the type of cluster ("true" for managed and "false" for self-managed).
3. Run the full_deploy.sh script to deploy the example application.
4. After the application is fully deployed and every Kubernetes object is ready, either:
    - Run persistence_between_nodes_test.sh to verify that the database is persistent between nodes
    - Run persistence_on_pod_failure.sh to verify that the database is persistent between pods on the same node
