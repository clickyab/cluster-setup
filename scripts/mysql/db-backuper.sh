#!/bin/bash

# define default values for variables.
hostname="localhost"
port="3306"
username="root"
password="123456"
database=""                          # in default backup from all of databases.
rbackup_dir="/backup2/mysql"         # upload backedup files in this directory.
lbackup_dir="/root/mysql"            # use as this directory to backup.
logfile="/var/log/mysql-backup-$(date +\"%Y%m%d\").log"
tmpfile="/tmp/mysql-backup-$(echo $$).log"
mysqld=$(which mysqld)

# initialize variables with new values.
while getopts ":h:u:p:d:r:" opt; do
    case $opt in
        h) hostname=$OPTARG;;
        u) username=$OPTARG;;
        p) password=$OPTARG;;
        d) database=$OPTARG;;
        r) rbackup_dir=$OPTARG;;
        l) lbackup_dir=$OPTARG;;
        \?) echo "Invalid option: -$OPTARG" >&2
            exit 1;;
        :) echo "Option -$OPTARG requires an argument." >&2
           exit 1;;
    esac
done

# define needed functions.
function backup() {
    # check mysql server status.
    msg=$(ps ax | grep -i $mysqld | grep -v "grep" 2>&1)
    if [ -z $msg ]; then
        echo "[×] MySQL service is NOT RUNNING." >> $logfile
        return 1
    else
        echo "[✓] MySQL service is RUNNING." >> $logfile
    fi

    # create backup directory
    msg=$(mkdir $lbackup_dir 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] We have a problem in creating local backup directory." >> $logfile
        echo "    Use as default directory '${lbackup_dir}'" >> $logfile
        lbackup_dir="/root/mysql"
        msg=$(mkdir $lbackup_dir 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "[×] We have a problem in creating default backup directory." >> $logfile
            return 1
        else
            echo "[✓] Create defalt backup directory successfully."
        fi
    else
        echo "[✓] Create local backup directory successfully."
    fi

    # taking full backup
    if [ -z $database ]; then
        msg=$(innobackupex --user=$username --password=$password --host=$hostname --port=3306 $lbackup_dir > $tmpfile 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "[×] An Error occured in innobackupex command." >> $logfile
            return 1
        else
            echo "[✓] Innobackupex command successfully completed." >> $logfile
        fi
    else
        msg=$(innobackupex --user=$username --password=$password --host=$hostname --port=3306 --databases=$database $lbackup_dir > $tmpfile 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "[×] An Error occured in innobackupex command." >> $logfile
            return 1
        else
            echo "[✓] Innobackupex command successfully completed." >> $logfile
        fi
    fi

    # prepare the backup
    msg=$(innobackupex --apply-log $lbackup_dir 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] An Error occured in preparing backup file." >> $logfile
        return 1
    else
        echo "[✓] successfully prepare the backup." >> $logfile
    fi
    return 0
}

function transfer() {
    msg=$(rsync --checksum --recursive --archive -e "ssh -p 6570" $lbackup_dir root@88.198.13.41:$rbackup_dir 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] We have an error in transfering backup files via rsync." >> $logfile
        echo "    $msg" >> $logfile
    else
        echo "[✓] backup files successfully transfered." >> $logfile
    fi
}

function send_report() {
    if [ $backup_status == "fail" ]; then
        subject="[FAIL] DB Backup Process Failed."
        echo -e "DataBase backing up proccess failed.\nTo find this problem reason, please check an attachment." >> /tmp/mail-body-$(date +"%Y%m%d").txt
        EMAIL="backup <no-replay@clickyab.com>" mutt -s ${subject} -a $logfile -- sysadmin@clickyab.com
    fi
    if [ $backup_status == "success" ]; then
        subject="[SUCCESS] DB Backup Process Complete Successfully."
        echo -e "DataBase backing up proccess complete successfully.\nTo find this process details, please check an attachment." >> /tmp/mail-body-$(date +"%Y%m%d").txt
        EMAIL="backup <no-replay@clickyab.com>" mutt -s ${subject} -a $logfile -- sysadmin@clickyab.com
    fi
}

function remove_old(){
    # remove local directory
    msg=$(rm -r $lbackup_dir/$(date +"%F")* 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] We have an error in removing local backup files." >> $logfile
        echo "    $msg" >> $logfile
    else
        echo "[✓] backup files successfully removed." >> $logfile
    fi
    # remove old remote backup directory
    msg$(ssh root@88.198.13.41 -p 6570 rm -r $rbackup_dir/$(date --date="3 days ago" +"%y%m%d")* 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] We have an error in removing old remote backup files." >> $logfile
        echo "    $msg" >> $logfile
    else
        echo "[✓] backup files successfully removed." >> $logfile
    fi
}

# main of script.
echo "Taking backup proccess is Start at $(date +"%F") ..." > $logfile

msg=$(backup 2>&1)
if [[ $? -ne 0 ]]; then
    backup_status="fail"
    send_report
    exit 0
else
    backup_status="success"
    msg=$(transfer 2>&1)
    if [[ $? -ne 0 ]]; then
        backup_status="fail"
        send_report
        exit 0
    else
        remove_old
        send_report $backup_status
    fi
fi

exit 0
