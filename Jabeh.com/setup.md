# Pre Requisites for install and running Jabeh.com

## Install web server:
To it purpose we use as nginx web server, for installing it run bellow commands:
```
apt-get update
apt-get install nginx
```
Create Jabeh.com virtual host file in `/etc/nginx/sites-available/` directory and copy bellow lines to that:
```bash
server {
        listen 5000;
        server_name  www.jabeh.com;
        return       301 $scheme://jabeh.com:$server_port$request_uri;
}

server {
        listen 5000 default_server;
        root /docker/jabeh/public/public; # root directory (your codes location on disk)
        server_name jabeh.com;
        charset UTF-8;
        index index.php;
        # Logs
        access_log  /var/log/nginx/jabeh_access.log;
        error_log /var/log/nginx/jabeh_error.log;

        location / {
                 try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
                proxy_intercept_errors on;
                fastcgi_pass unix:/run/php/php7.0-fpm.sock; # fpm socket file!!
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_intercept_errors on;
                include fastcgi_params;
                fastcgi_connect_timeout 3000;
                fastcgi_read_timeout    3000;
                fastcgi_keep_conn on;
        }

        location = /favicon.ico {
        log_not_found off;
        access_log off;
        }

        location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
        }

        location ~ /\.git/* {
        deny all;
        }
        # location /vts {
        #         auth_basic "Restricted Content";
        #         auth_basic_user_file /etc/nginx/.vtshtpasswd;
        #         vhost_traffic_status_display;
        #         vhost_traffic_status_display_format html;
        # }

}
```
save it in `jabeh.com` name.
First `server` block force nginx to redirect all `www.jabeh.com` requests to `jabeh.com`.

Now we should create symbolic link from it on `/etc/nginx/sites-enabled` directory.
```bash
ln -s /etc/nginx/sites-avialable/jabeh.com /etc/nginx/sites-enabled/jabeh.com
```
restart nginx service:
```bash
systemctl nginx restart
```

## Install php-fpm:
```bash 
apt-get install php-fpm
```
We have two way to sending nginx request to fpm, `$host:$port` or `socket file`,
the easiest way is use as default way which is declared in `/etc/php/7.0/fpm/pool.d/www.conf` file (search about `listen`).
```bash
cat /etc/php/7.0/fpm/pool.d/www.conf | grep -v "^;\|^$"
```
Then edit `/etc/nginx/sites-available/jabeh.com` file again and enter the socket file absolut path to `fastcgi_pass` variabel in `location` block.
restart `nginx` service again.
```bash
systemctl restart nginx
```
## Install Jabeh.com dependencies:
```
apt-get install php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php7.0-ldap php7.0-mbstring
```
for last step restart couple of `nginx` and `fpm` services:
```bash
systemctl restart nginx
systemctl restart php7.0-fpm
```
