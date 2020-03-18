#!/bin/bash

# Get the pod where the MySQL instance exists
POD_OBJECT=`kubectl get pods -l app=mysql -o wide | grep -v NAME`
POD_NAME=`echo $POD_OBJECT | awk '{print $1}'`

echo $POD_NAME
