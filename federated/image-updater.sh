#!/bin/bash

OUTPUT=$(docker pull registry.clickyab.ae/clickyab/crane_master:latest)
RETURN_CODE=${?}
if [[ ${RETURN_CODE} -ne 0 ]]; then
    echo "Error while pull image"
    exit 1
fi

OUTPUT=$(echo "${OUTPUT}" | grep "Image is up to date")
RETURN_CODE=$?
if [[ ${RETURN_CODE} -ne 0 ]]; then
    cd /root/crane/
    docker-compose stop app
    docker-compose rm --force app
    docker-compose up -d
fi

exit 0
