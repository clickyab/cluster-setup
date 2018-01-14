#!/bin/bash

# define default values for variables.
hostname="localhost"
port="3306"
username="root"
password="123456"
database=""                          # in default backup from all of databases.
rbackup_file="/backup2/mysql"         # upload backedup files on this file.
lbackup_file="/root/mysql.sql"        # sql backup saved in this file.
logfile="/var/log/mysql-backup-$(date +%Y%m%d).log"
tmpfile="/tmp/mysql-backup-$(echo $$).log"

# initialize variables with new values.
while getopts ":h:u:p:b:d:r:l:" opt; do
    case $opt in
        h) hostname=$OPTARG;;
        u) username=$OPTARG;;
        p) password=$OPTARG;;
        d) database=$OPTARG;;
        b) backup_server=${OPTARG};;
        r) rbackup_file=$OPTARG;;
        l) lbackup_file=$OPTARG;;
        \?) echo "Invalid option: -$OPTARG" >&2
            exit 1;;
        :) echo "Option -$OPTARG requires an argument." >&2
           exit 1;;
    esac
done

# define needed functions.
function backup() {
    # taking full backup
    if [ -z $database ]; then
        msg=$(mysqldump --verbose --user=$username --password=$password --host=$hostname --port="${port}" --result-file=$lbackup_file)
        if [[ $? -ne 0 ]]; then
            echo "[×] An Error occured in mysqldump command." >> $logfile
            echo "    $msg" >> $logfile
            return 1
        else
            echo "[✓] Mysqldump command successfully completed." >> $logfile
        fi
    else
        msg=$(mysqldump --verbose --user=$username --password=$password --host=$hostname --port="${port}" --databases $database --result-file=$lbackup_file)
        if [[ $? -ne 0 ]]; then
            echo "[×] An Error occured in mysqldump command." >> $logfile
            echo "    $msg" >> $logfile
            return 1
        else
            echo "[✓] Myqldump command successfully completed." >> $logfile
        fi
    fi
    return 0
}

function transfer() {
    msg=$(rsync --checksum --recursive --archive -e "ssh -p 6570 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" $lbackup_file root@${backup_server}:$rbackup_file 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] We have an error in transfering backup files via rsync." >> $logfile
        echo "    $msg" >> $logfile
    else
        echo "[✓] backup files successfully transfered." >> $logfile
    fi
}

# main of script.
echo "Taking backup process is Start at $(date +"%F") ..." > $logfile

msg=$(backup 2>&1)
if [[ $? -ne 0 ]]; then
    backup_status="fail"
    exit 0
else
    backup_status="success"
    msg=$(transfer 2>&1)
    if [[ $? -ne 0 ]]; then
        backup_status="fail"
        exit 0
    fi
fi

exit 0
