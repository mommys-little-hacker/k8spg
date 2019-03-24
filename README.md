# k8spg - COMING SOON

Kubernetes-native backups and disaster recovery for PostgreSQL, battle tested
in production environment.

## Current stage

ALPHA release

Source code and manifest clean up for GA. Removing 'artifacts' from old
deployments

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

## Credits

* [WAL-G](https://github.com/wal-g/wal-g) project for backup creation and
management;
* [Supercronic](https://github.com/aptible/supercronic) - docker-native cron
implementation;
* [gosu](https://github.com/tianon/gosu) to avoid running processes as root;
* Ships "World" database example for testing purposes from [PGFoundry
example databases](http://pgfoundry.org/projects/dbsamples/).
