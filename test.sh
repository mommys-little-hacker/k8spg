#!/bin/bash
# Author: Maxim Vasilev <admin@qwertys.ru>
# Description: Run test set up of k8spg

# Raise an error in case of unbound var
set -u
myname=`basename $0`

###
# Options
###

# Path to save credentials for reuse
secret_path=${K8SPG_SECRET-"./test/secret.yml"}
# Time in seconds to sleep after minikube start for stabilization
init_sleep=20

# Path to log file (use stdout to print to terminal)
log_path="stdout"
# Redirect output by child processes to log
log_applications=false
debug_enabled=true

###
# Globs
###

# Error codes
E_MISC=20
E_ARGS=21
E_INIT=22

# Log messages
LOG_INIT="Minikube is up"
LOG_SECRET="Credentials uploaded to minikube and saved for reuse in $secret_path"

LOG_E_MISC="Unknown error occurred."
LOG_E_ARGS="Invalid arguments supplied."
LOG_E_INIT="Failed to bring minikube up."

###
# Functions
###

# Logging function (KO to the rescue)
logEvent() {
    timestamp=`date -R`
    log_msg="$@"

    if [[ $log_path = "stdout" ]]
    then
        echo "[$timestamp] $log_msg"
    else
        echo "[$timestamp] $log_msg" >> $log_path
    fi
}

# Panic function
errorExit() {
    exit_code=$1
    shift
    logEvent "$@"
    exit $exit_code
}

minikubeInit() {
    set -e
    minikube status > /dev/null || minikube start 2>&1 > /dev/null

    sleep $init_sleep
}

createSecret() {
    set -e
    if [[ -f $secret_path ]]
    then
        kubectl create -f $secret_path
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

        kubectl get secret k8spg -o yaml > $secret_path
    fi
}

###
# main()
###

minikubeInit || errorExit $E_INIT "$LOG_E_INIT"
logEvent "$LOG_INIT"
createSecret
logEvent "$LOG_SECRET"

kubectl create configmap k8spg --from-file=./conf
kubectl create -f ./k8s/
