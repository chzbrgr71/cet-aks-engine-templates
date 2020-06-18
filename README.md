## aks-engine testing

### Deploy aks-engine cluster

```bash
export RGNAME=aks-engine
export LOCATION=eastus
export CLUSTERNAME=aks-engine-testing
export CLIENTID=
export CLIENTSECRET=
export SUBSCRIPTIONID=
export TENANTID=
export VNETNAME=cluster-vnet
export SUBNETNAME=node-subnet
export AGENTSUBNET=node-subnet

az group create --name $RGNAME --location $LOCATION

az network vnet create --resource-group virtual-networks --name $VNETNAME --address-prefixes 10.100.0.0/24 10.200.0.0/24 --subnet-name $SUBNETNAME --subnet-prefixes 10.100.0.0/24

aks-engine deploy \
    --subscription-id $SUBSCRIPTIONID \
    --dns-prefix $CLUSTERNAME \
    --resource-group $RGNAME \
    --location $LOCATION \
    --api-model kubernetes-br.json \
    --client-id $CLIENTID \
    --client-secret $CLIENTSECRET \
    --force-overwrite
```

### Attach routetable to VNET
https://github.com/Azure/aks-engine/blob/master/docs/tutorials/custom-vnet.md#post-deployment-attach-cluster-route-table-to-vnet 

```bash
rt=$(az network route-table list -g $RGNAME -o json | jq -r '.[].id')

az network vnet subnet update -n $SUBNETNAME \
-g virtual-networks \
--vnet-name $VNETNAME \
--route-table $rt
```

### Deploy and Scale App

```bash
kubectl apply -f nginx.yaml

kubectl scale deployment nginx --replicas=5
kubectl scale deployment nginx --replicas=1000

kubectl scale deployment mysql-deployment --replicas=2
```

### Istio

https://istio.io/docs/setup/getting-started 

```bash
curl -L https://istio.io/downloadIstio | sh -

istioctl version --remote=false

istioctl manifest apply --set profile=demo

# sample app
kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled
kubectl apply -f /Users/brianredmond/source/istio-1.4.5/samples/bookinfo/platform/kube/bookinfo.yaml -n bookinfo

kubectl apply -f /Users/brianredmond/source/istio-1.4.5/samples/bookinfo/networking/bookinfo-gateway.yaml -n bookinfo

kubectl get svc istio-ingressgateway -n istio-system
```

