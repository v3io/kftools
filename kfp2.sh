#!/usr/bin/env bash

# Note, the mount entry points should exist on the HOST machine and have proper permissions
mkdir -p /tmp/mnt/pv1 /tmp/mnt/pv2 /tmp/mnt/pv3

curl -OL https://raw.githubusercontent.com/v3io/kftools/master/add-pv.yaml
# Modify the original yaml to make mounts at /tmp directory (accessible for everybody)
sed -i '' "s/\/mnt/\/tmp\/mnt/g" add-pv.yaml
# run this to create PVs
kubectl create -f add-pv.yaml

export KFNAMESPACE="default-tenant"
# Note, following environment variables should contain proper values for target system
export IGZDOMAIN="igor-playground.iguazio-cd2.com"
export IGZ_ACCESS_KEY="8c9bcf45-53b1-46da-a9fa-dcc6267a7f19"

#curl -OL https://raw.githubusercontent.com/v3io/kftools/master/full-install.yaml
cp ./full-install.yaml.template ./full-install.yaml
sed -i '' "s/<namespace>/${KFNAMESPACE}/g" full-install.yaml

if [[ ! -z "${IGZ_ACCESS_KEY}" ]]; then
    sed -i '' "s/<accesskey>/${IGZ_ACCESS_KEY}/g" full-install.yaml
fi

kubectl create -f full-install.yaml

if [[ ! -z "${IGZDOMAIN}" ]]; then
    curl -OL https://raw.githubusercontent.com/v3io/kftools/master/ing.yaml
    sed -i '' "s/<namespace>/${KFNAMESPACE}/g; s/<domain>/${IGZDOMAIN}/g" ing.yaml
    kubectl create -f ing.yaml
fi
