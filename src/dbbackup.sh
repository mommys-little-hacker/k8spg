#!/bin/bash
# Author: Maxim Vasilev <admin@qwertys.ru>
# Description: Backup PostgreSQL instance and upload it to S3

# Raise an error in case of unbound var
set -u
myname=`basename $0`

###
# Options
###

conffile=/etc/postgresql/restore.env

# Path to log file
log_path="/dev/stdout"
log_applications=false

###
# Globs
###

# Error codes
E_MISC=20
E_ARGS=21
E_RUNNING=22
E_CONF=23
E_BACKUP=24

# Log messages

LOG_STARTED="Uploading backup"
LOG_COMPLETE="Backup complete."
LOG_DISABLED="Automatic backup disabled. To create backup, run this script with 'BACKUP_ENABLED=true'."

LOG_E_MISC="Unknown error occurred."
LOG_E_ARGS="Invalid arguments supplied."
LOG_E_RUNNING="WAL-G is running already, aborting."
LOG_E_CONF="Invalid or missing configuration"
LOG_E_BACKUP="Failed to upload backup!"

###
# Functions
###

# Logging function (KO to the rescue)
logEvent() {
    timestamp=`date -R`
    log_msg="$@"

    if [[ ${log_path-stdout} = "stdout" ]]
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
    if [[ $# > 0 ]]; then logEvent "$@"; fi
    exit $exit_code
}

createBackup() {
    wal-g backup-push $backup_dir || errorExit $E_BACKUP $LOG_E_BACKUP
}

isRunningAlready() {
    ps --no-headers -C wal-g && errorExit $E_RUNNING $LOG_E_RUNNING
    return 0
}

# Redirect output
if [ "$log_applications" = "true" ]
then
    exec >> "$log_path"
    exec 2>> "$log_path"
fi

###
# main()
###

. $conffile || errorExit $E_CONF $LOG_E_CONF

# Directory to backup
backup_dir="${PG_DATA}"

db_user=${1-${PGUSER-postgres}}
db_pass=${2-${PGPASSWORD-""}}
db_host=${3-${PGHOST-"localhost"}}
db_port=${4-${PGPORT-5432}}

logEvent $LOG_STARTED
isRunningAlready
createBackup
logEvent $LOG_COMPLETE
