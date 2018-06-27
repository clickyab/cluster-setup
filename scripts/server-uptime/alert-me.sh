#!/usr/bin/env bash

EMAIL_RECEPTOR="sysadmin@clickyab.com"
SMS_RECEPTOR="09107588522, 09124966428"
KN_API_KEY="64732B7933574D494571665135736B574C41456B52773D3D"
HOSTNAME=$(hostname)
TIME=$(date +"%F %T")
TITLE="[ATTENTION] $HOSTNAME RESTARTED."
MESSAGE="At $TIME $HOSTNAME restarted."

echo "${MESSAGE}" | EMAIL="CY EYES <no-reply@clickyab.com>" mutt -s "${TITLE}" -- ${EMAIL_RECEPTOR}

curl -X POST http://api.kavenegar.com/v1/${KN_API_KEY}/sms/send.json --data-urlencode "receptor=${SMS_RECEPTOR}" --data-urlencode "message=${TITLE} ${MESSAGE}"
