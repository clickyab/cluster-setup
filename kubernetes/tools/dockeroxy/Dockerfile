FROM ubuntu:16.04
MAINTAINER vahit <vahid.maani@gmail.com>

## update packages and install openssh-server
RUN apt-get update && apt-get install -y openssh-server

## Permit root user login
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config

## transfer entrypoint file to /root
COPY ./entrypoint.sh /root/

## expose 22 port
EXPOSE 22

CMD ["/bin/bash","/root/entrypoint.sh"]
