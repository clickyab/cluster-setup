# Install kubernetes

## Requirements

### Docker

Install `docker-ce` the version tested in this dockument was :

```
Client:
 Version:      17.06.0-ce
 API version:  1.30
 Go version:   go1.8.3
 Git commit:   02c1d87
 Built:        Fri Jun 23 21:23:31 2017
 OS/Arch:      linux/amd64

Server:
 Version:      17.06.0-ce
 API version:  1.30 (minimum version 1.12)
 Go version:   go1.8.3
 Git commit:   02c1d87
 Built:        Fri Jun 23 21:19:04 2017
 OS/Arch:      linux/amd64
 Experimental: false
```

Make sure update this documents, if we need to update docker.

TODO: add instruction for install docker on system in exact version

### Install kubeadm

We use kubeadm to setup kubernetes. currently the entire cluster version is `1.7.0` update this document if we need to change it.

```
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm
```

TODO: update instruction with the propert version

### Install nginx (as load balancer)

Install nginx and make sure its configured with one host. the ingress is not yet ready, we use an ingress, but as `NodePort` service on port `30080`. so make sure *ALL* requests from port `80` forwarded to port `127.0.0.1:30080` that we setup ingress on that port.

configs are :

/etc/nginx/nginx.conf
```
user www-data;
worker_processes auto;
pid /run/nginx.pid;
worker_rlimit_nofile 1000000;


events {
        worker_connections 120000;
        multi_accept on;
        use epoll;
}

http {
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;
        access_log off;
        error_log  /var/log/nginx/error.log crit;
        underscores_in_headers on;
        #access_log /var/log/nginx/access.log;
        #error_log /var/log/nginx/error.log;
        #limit_req_zone $binary_remote_addr zone=blitz:5m rate=1000r/s;
        #limit_req zone=blitz  burst=1000;
        gzip on;
        gzip_min_length 10240;
        gzip_proxied expired no-cache no-store private auth;
        gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
        gzip_disable "msie6";

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
```

/etc/nginx/sites-enabled/default:

```
server {
        listen 80 default_server;
        #listen [::]:80 default_server;
        root /var/www/html;
        server_name _;
        location / {
                proxy_pass http://127.0.0.1:30080;
                proxy_set_header Host $http_host;
        }
}
```

TODO: IPv6 is disabled due to conflict with old nginx container for legecy showad. decide when the legecy code is done.

## Setup the first node

NOTE : If the node is already done, go to add new node section.

make sure the node is clean and the requirements are installed. See general/setup.md (TODO: make links) if any step failed or there is an old cluster available, call `kubead reset` to reset the old installation.

start the kubeadm (the pod-network is required for flannel only):

````
kubeadm init --pod-network-cidr=10.11.0.0/16
````
NOTE : the output is important. pipe it into a file and store it afterward in `pass` storage. setup the `kubectl` command in another user (not root) in the same machine and all machine needed to access to it.

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

make sure cluster is up.
```
$ kubectl get nodes
NAME               STATUS     AGE       VERSION
bd-1.clickyab.ae   NotReady   1m        v1.7.0
```

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE
kube-system   kube-apiserver-bd-1.clickyab.ae            1/1       Running   0          23s
kube-system   kube-controller-manager-bd-1.clickyab.ae   1/1       Running   0          16s
kube-system   kube-dns-2425271678-gxltx                  0/3       Pending   0          57s
kube-system   kube-proxy-drnj6                           1/1       Running   0          57s
kube-system   kube-scheduler-bd-1.clickyab.ae            1/1       Running   0          21s
```

### Setup pod networking

TODO : Currently we use flannel, make a compare with other and choose the best

apply all files in calico folder :

NOTE: Make sure you are in repository root

```
$ kubectl apply -f kubernetes/flannel/flannel-setup.yaml
```

make sure the dns pod is active and ready :

```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE
kube-system   etcd-bd-1.clickyab.ae                      1/1       Running   0          17m
kube-system   kube-apiserver-bd-1.clickyab.ae            1/1       Running   0          18m
kube-system   kube-controller-manager-bd-1.clickyab.ae   1/1       Running   0          18m
kube-system   kube-dns-2425271678-gxltx                  3/3       Running   0          18m <-- this one
kube-system   kube-flannel-ds-r804g                      2/2       Running   0          9m
kube-system   kube-proxy-drnj6                           1/1       Running   0          18m
kube-system   kube-scheduler-bd-1.clickyab.ae            1/1       Running   0          18m

```

### Setup dashboard

Use the yaml file in dashboard

```
$ kubectl apply -f kubernetes/dashboard/kube-dashboard.yml
```
confirm that the pod is alive, with `kubectl get pods --all-namespaces`

### Setup ingress

NOTE : This is very experimental, and may change

```
$ kubectl apply -f kubernetes/ingress/ingress-setup.yml
```

confirm all ingress service/controllers are ready. 

## Add new nodes

Check for the file from the first node installation. some thing like this :

```
$ kubeadm join --token <token> <master-ip>:6443
```

The state should updated after a minute or so.

```
$ kubectl get nodes
NAME                  STATUS    AGE       VERSION
bd-1.clickyab.ae      Ready     13m       v1.7.0
redis-2.clickyab.ae   Ready     12m       v1.7.0
redis-3.clickyab.ae   Ready     11m       v1.7.0
```

## Private docker registry

Since we use private docker registry we need to handle this for kubelet. 
first login into private registry : 

```bash 
docker login registry.clickyab.ae
```

But the problem is the the systemass (sorry , I mean systemd) can not use the $HOME variable
 and the config is not available for kubelete process we need to add some env to docker :
 
```bash 
EDITOR=mycooleditor # Use your editor 
systemctl edit kubelet 
```

Must open an empty file put this in it (assume you login with root user ): 

```
[Service]
Environment=HOME=/root
```

then `systemctl restart  kubelet`