#!/bin/bash -ex
# script to install Kubeflow (only pipeline)

# set kubeflow vars
export KFVER=0.5.0
export KFAPP=$(pwd)/kfapp
export KFNAMESPACE=kubeflow

# create PVC for minio, mysql
sudo mkdir /mnt/pv1
sudo mkdir /mnt/pv2
sudo mkdir /mnt/pv3

# run this to create PVs
kubectl create -f https://raw.githubusercontent.com/v3io/kftools/master/add-pv.yaml

# install ksonnet (optional for debug)
mkdir bin
curl -OL https://github.com/ksonnet/ksonnet/releases/download/v0.13.1/ks_0.13.1_linux_amd64.tar.gz
tar zxf ks_0.13.1_linux_amd64.tar.gz
cp ks_0.13.1_linux_amd64/ks bin/
rm ks_0.13.1_linux_amd64.tar.gz
rm -Rf ks_0.13.1_linux_amd64/

# install kubeflow
curl -OL https://github.com/kubeflow/kubeflow/releases/download/v${KFVER}/kfctl_v${KFVER}_linux.tar.gz
tar -xvf kfctl_v${KFVER}_linux.tar.gz
cp kfctl bin/
rm kfctl
rm kfctl_v${KFVER}_linux.tar.gz
export PATH=$PATH:$(pwd)/bin

kfctl init ${KFAPP}
cd ${KFAPP}

# REPLACE app.yaml with the one below !!! (remove unwanted kubeflow components)
curl -OL https://raw.githubusercontent.com/v3io/kftools/master/app.yaml
sed -i "s/<namespace>/${KFNAMESPACE}/g" app.yaml

# install
kfctl generate k8s -V
kfctl apply k8s -V

kubectl -n kubeflow get  all

if [[ -z "${IGZDOMAIN}"] ]; then
    curl -OL https://raw.githubusercontent.com/v3io/kftools/master/ing.yaml
    sed -i "s/<namespace>/${KFNAMESPACE}/g; s/<domain>/${IGZDOMAIN}/g" ing.yaml
    kubectl create -f ing.yaml
fi

# expose pipeline ui as NodePort
if [[ -z "${KFNODEPORT}"] ]; then
    kubectl -n kubeflow patch service/ml-pipeline-ui -o yaml -p {"spec":{"ports":[{"nodePort":${KFNODEPORT},"port":80,"protocol":"TCP","targetPort":3000}],"type":"NodePort"}}
fi

# optional expose minio service
# kubectl -n kubeflow patch service/minio-service -p '{"spec":{"type":"NodePort"}}' -o yaml

# delete completes PODs, not recommended
# kubectl -n kubeflow get pods --no-headers=true |grep -v "Running" | grep -v "Pending" | sed -E 's/([a-z0-9-]+).*/\1/g' | xargs kubectl -n kubeflow delete pod