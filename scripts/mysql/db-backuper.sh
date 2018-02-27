#!/bin/bash

# define default values for variables.
hostname="localhost"
port="3306"
username="root"
password="123456"
database=""                          # in default backup from all of databases.
rbackup_dir="/backup2/mysql"         # upload backedup files in this directory.
lbackup_dir="/root/mysql"            # use as this directory to backup.
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
   # create backup directory
    if [[ ! -d $lbackup_dir ]]; then
        msg=$(mkdir $lbackup_dir 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "[×] We have a problem in creating local backup directory." >> $logfile
            echo "    $msg" >> $logfile
            echo "    Use as default directory '${lbackup_dir}'" >> $logfile
            lbackup_dir="/root/mysql"
        else
            echo "[✓] Create local backup directory successfully." >> $logfile
        fi
    else
        echo "[✓] $lbackup_dir exists." >> $logfile
    fi

    # taking full backup
    if [ -z $database ]; then
        msg=$(innobackupex --user=$username --password=$password --host=$hostname --port="${port}" $lbackup_dir > $tmpfile 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "[×] An Error occured in innobackupex command." >> $logfile
            echo "    $msg" >> $logfile
            return 1
        else
            echo "[✓] Innobackupex command successfully completed." >> $logfile
        fi
    else
        msg=$(innobackupex --user=$username --password=$password --host=$hostname --port="${port}" --databases=$database $lbackup_dir > $tmpfile 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "[×] An Error occured in innobackupex command." >> $logfile
            echo "    $msg" >> $logfile
            return 1
        else
            echo "[✓] Innobackupex command successfully completed." >> $logfile
        fi
    fi

    # prepare the backup
    msg=$(innobackupex --apply-log $lbackup_dir/$(date +"%F")* 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] An Error occured in preparing backup file." >> $logfile
        echo "    $msg" >> $logfile
        return 1
    else
        echo "[✓] successfully prepare the backup." >> $logfile
    fi
    return 0
}

function transfer() {
    msg=$(rsync --checksum --recursive --archive -e "ssh -p 6570" $lbackup_dir/* root@${backup_server}:$rbackup_dir/ 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] We have an error in transfering backup files via rsync." >> $logfile
        echo "    $msg" >> $logfile
        return 1
    else
        echo "[✓] backup files successfully transfered." >> $logfile
        return 0
    fi
}

function send_report() {
    if [ $backup_status == "fail" ]; then
        subject="[FAILED] DB Backup Process Failed."
        echo -e "DataBase backing up process failed.\nTo find this problem reason, please check below list:" > /tmp/mail-body-$(date +"%Y%m%d").txt
        cat $logfile >> /tmp/mail-body-$(date +"%Y%m%d").txt
        EMAIL="backup <no-reply@clickyab.com>" mutt -s "${subject}" -- sysadmin@clickyab.com < /tmp/mail-body-$(date +"%Y%m%d").txt
    fi
    if [ $backup_status == "success" ]; then
        subject="[SUCCESS] DB Backup Process Complete Successfully."
        echo -e "DataBase backing up process complete successfully.\nTo find this process details, please check below list:" > /tmp/mail-body-$(date +"%Y%m%d").txt
        cat $logfile >> /tmp/mail-body-$(date +"%Y%m%d").txt
        EMAIL="backup <no-reply@clickyab.com>" mutt -s "${subject}" -- sysadmin@clickyab.com < /tmp/mail-body-$(date +"%Y%m%d").txt
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
    msg=$(ssh root@${backup_server} -p 6570 rm -r $rbackup_dir/$(date --date="3 days ago" +"%F")* 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "[×] We have an error in removing old remote backup files." >> $logfile
        echo "    $msg" >> $logfile
    else
        echo "[✓] backup files successfully removed." >> $logfile
    fi
}

# main of script.
echo "Taking backup process is Start at $(date +"%F") ..." > $logfile

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
        send_report
    fi
fi

exit 0
