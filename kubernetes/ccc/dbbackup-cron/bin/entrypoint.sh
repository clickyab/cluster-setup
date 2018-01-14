#!/bin/bash

set -eo pipefail

mkdir -p /var/run/sshd
chmod 600 -R /root/.ssh

bash -x /root/db-backuper.sh -u "${DB_USER}" -p "${DB_PASS}" -h "${DB_HOST}" -d "${DB_NAME}" -l /root/"${FILE_NAME}".sql -r /"${REMOTE_FILE}" -b "${BACKUP_SERVER}"

exit 0
