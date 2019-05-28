#!/usr/bin/env bash

sudo mkdir /mnt/pv1
sudo mkdir /mnt/pv2
sudo mkdir /mnt/pv3

# run this to create PVs
kubectl create -f https://raw.githubusercontent.com/v3io/kftools/master/add-pv.yaml

export KFNAMESPACE=default-tenant
export IGZDOMAIN=yaronh6.iguazio-cd2.com

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

