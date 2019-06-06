#!/usr/bin/env bash

kubectl delete -f ing.yaml
kubectl delete -f full-install.yaml
kubectl delete -f https://raw.githubusercontent.com/v3io/kftools/master/add-pv.yaml

RM -Rf /mnt/pv1
RM -Rf /mnt/pv2
RM -Rf /mnt/pv3
