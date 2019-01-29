#!/bin/bash

secret=${K8SPG_SECRET-"./test/secret.yml"}

minikube status || minikube start

if [[ -f $secret ]]
then
    kubectl create -f $secret
else
    echo 'Set superuser password:'
    read pgpass
    echo 'Enter your S3 bucket URL (e. g. s3://bucket/path/to/folder):'
    read aws_s3_url
    echo 'Enter your AWS AMI key id:'
    read aws_key_id
    echo 'Enter your AWS AMI secret key:'
    read aws_key_secret

    kubectl create secret generic k8spg \
      --from-literal=postgres-password=${pgpass} \
      --from-literal=aws-s3-url=${aws_s3_url} \
      --from-literal=aws-key-id=${aws_key_id} \
      --from-literal=aws-key-secret=${aws_key_secret}
fi

kubectl create configmap k8spg --from-file=./conf
kubectl create -f ./k8s/
