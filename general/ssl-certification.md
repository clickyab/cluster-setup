# Create/Renew ssl certification via certbot

1. stop nginx `systemctl stop nginx`
2. run certbot `certbot certonly`
3. select first element "Spin up a temporary webserver (standalone)"
4. enter the desired domain.
...
x. start nginx `systemctl start nginx`

