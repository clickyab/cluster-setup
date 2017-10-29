# Redis cluster in kubernetes 

## Setup

Just use all yaml file inside this directory. 

### Notes 

1- Configs are stored inside the `/etc/globalconf/redis-{,cluster}-{id}.conf` this folder is mounted from ceph cluster
so its ok to restart pods and the configs are fine even if there is no data. remember the data is wiped on 
pod on restart, but config are not, just use `cluster meet` to find peers in case of ip change after restart 
(which is done in bootstraping the pod) 

2- The cluster slots are all on the node 0 of stateful-set on initialization, use redis-trib utility to reorder them. 
``` 
kubectl run -i --tty redis-tribe --image=zvelo/redis-trib --restart=Never -- reshard --from {MASTER-NODE-ID} --to {ANOTHER-MASTER-ID} --slots 2730 --yes {IP-OF-ONE-POD-IN-CLUSTER}:6379
``` 