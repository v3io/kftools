#!/usr/bin/env bash

kubectl delete -f ing.yaml
kubectl delete -f full-install.yaml
kubectl delete -f https://raw.githubusercontent.com/v3io/kftools/master/add-pv.yaml

rm -Rf /tmp/mnt/pv1
rm -Rf /tmp/mnt/pv2
