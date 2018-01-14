FROM alpine:latest
MAINTAINER vahit<vahid.maani@gmail.com>

RUN apk update && \
    apk add --no-cache bash rsync openssh mysql-client

COPY ./bin/ /root
RUN mkdir -p /root/.ssh

ENTRYPOINT ["bash", "/root/entrypoint.sh"]

