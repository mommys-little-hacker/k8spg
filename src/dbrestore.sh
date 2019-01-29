#!/bin/bash
# Author: Maxim Vasilev <admin@qwertys.ru>
# Description: Restore database from backup

# Raise an error in case of unbound var
set -u
myname=`basename $0`

###
# Options
###

conffile=/etc/postgresql/restore.env
recovery_template=/etc/postgresql/recovery.conf.tmpl

# Path to log file
log_path="/dev/stdout"
log_applications=true

###
# Globs
###

# Error codes
E_MISC=20
E_BAD_ARGS=21
E_CLEAR=22
E_RESTORE=23

###
# Functions
###

logEvent() {
    timestamp=`date -R`
    log_msg="$@"

    echo "[$timestamp] $log_msg" >> $log_path
}

clearDir() {
    find $dbroot -mindepth 1 -delete
    if [[ $? = 0 ]]
    then
        logEvent "DB directory is clear"
    else
        logEvent "Failed to clear DB directory."
        return 1
    fi
}

restoreBackup() {
    wal-g backup-fetch $dbroot $BACKUP_NUM \
        && cat "$recovery_template" | envsubst > ${dbroot%%/}/recovery.conf \
        && chown -R ${uid}:${uid} $dbroot
    if [[ $? = 0 ]]
    then
        logEvent "Backup restored."
    else
        logEvent "Failed to restore backup!"
        return 1
    fi
}

# Backup current data dir
stashDatadir() {
    cp -rpf $dbroot $tmp_dir
    if [[ $? = 0 ]]
    then
        logEvent "Current instance is backed up."
    else
        logEvent "Failed to backup current instance!"
        rm -rf $tmp_dir
        return 1
    fi
}

# Revert all changes
unstashDatadir() {
    cp -rpfT $tmp_dir $dbroot
    if [[ $? = 0 ]]
    then
        logEvent "Changes reverted."
    else
        logEvent "Failed to revert changes!"
        return 1
    fi
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

. $conffile

dbroot=${PG_DATA-"/var/lib/postgresql/"}
uid=${PG_UID-999}
tmp_dir=/var/tmp/dbbackup/

if [[ $RESTORE_ON_START = "true" && $RESTORE_DATE && $RESTORE_NUM ]]
then
    export BACKUP_NUM=$RESTORE_NUM
    export BACKUP_DATE=`date -d "$RESTORE_DATE" +%Y-%m-%d\ %H:%M:%S`

    stashDatadir || exit 0
    clearDir || { unstashDatadir && exit 0; }
    restoreBackup || { clearDir && unstashDatadir && exit 0; }
else
    logEvent "Backup restore disabled or required params are not defined"
    exit 0
fi
