#!/usr/bin/env bash

HOSTNAME=$(hostname)
TIME=$(date +"%F %T")
TITLE="[ATTENTION] $HOSTNAME RESTARTED."
MESSAGE="At $TIME $HOSTNAME restarted."

echo "${MESSAGE}" | EMAIL="CY EYES <no-reply@clickyab.com>" mutt -s "${TITLE}" -- sysadmin@clickyab.com

