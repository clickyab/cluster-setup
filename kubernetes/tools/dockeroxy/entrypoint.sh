#!/bin/bash

set -eo pipefail

## change root user password
echo "root:${ROOT_PASSWORD}" | chpasswd

## make sshd needed ports
mkdir /root/.ssh/
mkdir /var/run/sshd

## Add ssh keys to root user
OLDIFS=${IFS}
IFS=$(echo -ne "\n\b")
SSH_KEYS=$(env | grep -i "^SSH_KEY")
for EACH_KEY in ${SSH_KEYS}; do
    echo ${EACH_KEY} | cut -d"=" -f2- | tee -a /root/.ssh/authorized_keys
done
IFS=${OLDIFS}

ROOT_LINE=$(cat /etc/passwd | grep "^root")
ROOT_NEW_LINE=$(echo ${ROOT_LINE} | sed 's/bash/nologin/g')
sed -ir "s|${ROOT_LINE}|${ROOT_NEW_LINE}|g" /etc/passwd

/usr/sbin/sshd -D 
