# Rabbitmq in brocker(s) server

## Installation
*NOTE:* Install the neweset version of rabbitmq using the instruction in the origin site, do not use the distro version

After installation make sure the ulimit is setup for this instance. in systemd, the limit is in different place use 
`systemctl edit rabbitmq-server` to create an override and put this in it :  

```ini
[Service]
LimitNOFILE=600000
```
DO NOT EDIT SERVICE FILE DIRECTLY!

## Setup management plugin

```bash
rabbitmq-plugins enable rabbitmq_management
# No install the admin 
wget -O /usr/bin/rabbitmqadmin http://127.0.0.1:15672/cli/rabbitmqadmin
chmod a+x /usr/bin/rabbitmqadmin
```

Now you can access to it using the port 15672 and via `rabbitmqadmin` command

## Create user 

*NOTE:* delete the guest user : `rabbitmqctl delete_user guest`
For the first user which is administrator use this : 

```bash
RUSER=dpr
RPASS=password
rabbitmqctl add_user ${RUSER} ${RPASS}
rabbitmqctl set_user_tags ${RUSER} administrator
rabbitmqctl set_permissions -p / ${RUSER} ".*" ".*" ".*"
```

## Create exchange per app 

```bash
# Must run it using admin user since the guest user is not available
VHOST=third
rabbitmqadmin -u ${RUSER} -p ${RPASS} declare vhost name=${VHOST}
NEWUSER=user
NEWPASS=pass
rabbitmqctl add_user ${NEWUSER} ${NEWPASS}
rabbitmqctl set_permissions -p ${VHOST} ${NEWUSER} ".*" ".*" ".*"
# Its a good idea to add admin user to this to 
rabbitmqctl set_permissions -p ${VHOST} ${RUSER} ".*" ".*" ".*"
# Its time to create dlx for queue (its important for debuging)
rabbitmqadmin -u ${RUSER} -p ${RPASS} --vhost ${VHOST} declare queue name=dlx-queue
rabbitmqadmin -u ${RUSER} -p ${RPASS} --vhost ${VHOST} declare exchange name=dlx-exchange type=topic
rabbitmqctl set_policy DLX ".*" '{"dead-letter-exchange":"dlx-exchange"}' --apply-to queues -p ${VHOST}
rabbitmqadmin -u ${RUSER} -p ${RPASS} --vhost ${VHOST} declare binding source="dlx-exchange" destination_type="queue" destination="dlx-queue" routing_key="#"
```