#!/bin/bash -x

SLEEP=${SLEEP:-86400}

function docker-gc () {
while :
do
	echo "Run docker-gc"
	/docker-gc
	sleep ${SLEEP}
done
}
docker-gc &

/node-problem-detector --system-log-monitors=/config/kernel-monitor.json
