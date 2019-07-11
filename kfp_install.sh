#!/usr/bin/env bash

mkdir -p /tmp/mnt/pv1 /tmp/mnt/pv2

# run this to create PVs
kubectl create -f https://raw.githubusercontent.com/v3io/kftools/master/add-pv.yaml

export KFNAMESPACE=default-tenant
export IGZDOMAIN=<domain>
export IGZ_ACCESS_KEY=<access-key>

curl -OL https://raw.githubusercontent.com/v3io/kftools/master/full-install.yaml
sed -i "s/<namespace>/${KFNAMESPACE}/g" full-install.yaml

if [[ -v IGZ_ACCESS_KEY ]]; then
    sed -i "s/<accesskey>/${IGZ_ACCESS_KEY}/g" full-install.yaml
fi

kubectl create -f full-install.yaml

if [[ -v IGZDOMAIN ]]; then
    curl -OL https://raw.githubusercontent.com/v3io/kftools/master/ing.yaml
    sed -i "s/<namespace>/${KFNAMESPACE}/g; s/<domain>/${IGZDOMAIN}/g" ing.yaml
    kubectl create -f ing.yaml
fi

