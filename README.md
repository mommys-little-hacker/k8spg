# k8spg

Kubernetes-native backups and disaster recovery for PostgreSQL, battle tested
in production environment.

**Current stage**: BETA

## Description

Designed to automate:

- backup creation;
- backup restoration;
- backup testing.

Goals:

- No vendor lock-in, you can deploy it to your own k8s installation;
- Based on original PostgreSQL docker images - no introduced bugs or backdoors;
- Uses original PostgreSQL configuration file - no wrappers like DSL or YAML,
you can configure it your own way.

Relies on utilizing kubernetes built-in entities (ConfigMap, Secret,
StatefulSet, etc.) solely, without any CRD's.

## Testing with Minikube

Just run the `test.sh`. This script will ask your cedentials for AWS S3 to save
WAL and backups and set password for `postgres` user. This script will also save
these credentials to `test/secret.yml` so you won't have to input them every
time you run this script.
```
user@localhost:~/Documents/k8spg$ ./test.sh 
There is a newer version of minikube available (v1.1.0).  Download it here:
https://github.com/kubernetes/minikube/releases/tag/v1.1.0

To disable this notification, run the following:
minikube config set WantUpdateNotification false
[Tue, 28 May 2019 18:50:32 +0300] Minikube is up
Set superuser password:
REDACTED
Enter your S3 bucket URL (e. g. s3://bucket/path/to/folder):
s3://REDACTED/minikube
Enter your AWS AMI key id:
REDACTED
Enter your AWS AMI secret key:
REDACTED
secret/k8spg created
[Tue, 28 May 2019 18:53:46 +0300] Credentials uploaded to minikube and saved for reuse in ./test/secret.yml
configmap/k8spg created
service/k8spg created
statefulset.apps/k8spg created
user@localhost:~/Documents/k8spg$
```

## Running in your K8s cluster

Currently, k8spg ships as YAML manifests for Kubernetes in `k8s` directory. Feel
free to adjust them to your liking (e. g. change the namespace or StatefulSet
name). After saving your changes, create k8s secret with your AWS S3 credentials
and `postgres` user password with the following command:
```
kubectl create secret generic k8spg \
  --from-literal=postgres-password=MY_SECURE_PASSWORD \
  --from-literal=aws-s3-url=MY_S3_URL \
  --from-literal=aws-key-id=MY_AWS_KEY_ID \
  --from-literal=aws-key-secret=MY_AWS_KEY_SECRET
```

Create k8spg configmap from files in conf directory:
```
kubectl create configmap k8spg --from-file=./conf
```

Run k8spg:
```
kubectl create -f ./k8s/
```

## Credits

* [WAL-G](https://github.com/wal-g/wal-g) project for backup creation and
management;
* [Supercronic](https://github.com/aptible/supercronic) - docker-native cron
implementation;
* [gosu](https://github.com/tianon/gosu) to avoid running processes as root;
* Ships "World" database example for testing purposes from [PGFoundry
example databases](http://pgfoundry.org/projects/dbsamples/).
