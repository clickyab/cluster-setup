#!/usr/bin/env bash

cd kubernetes-rabbitmq-cluster

export NAMESPACE=rabbitmq && \
export DOCKER_REPOSITORY=registry.clickyab.ae/clickyab && \
export RABBITMQ_REPLICAS=5 && \
export RABBITMQ_DEFAULT_USER=dpr && \
export RABBITMQ_DEFAULT_PASS=hooMah0Eahtis2Ah && \
export RABBITMQ_ERLANG_COOKIE=za4Ke9oiHiR4joQuloloRei2ce5ooSew && \
export RABBITMQ_EXPOSE_MANAGEMENT=TRUE && \
export RABBITMQ_MANAGEMENT_SERVICE_TYPE=ClusterIP && \
export RABBITMQ_HA_POLICY='{\"ha-mode\":\"exactly\",\"ha-params\":2,\"ha-sync-mode\":\"automatic\"}' && \
export RABBITMQ_LOG_LEVEL=info && \
export SUDO="" && \
export RBAC=TRUE && \
make deploy
