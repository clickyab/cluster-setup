# ceph cluster

## Preparation

### SSH setup

Make sure your system is allowed to connect without password via ssh to all nodes. 
we currently use local-system to do so. 
 
Make sure there is a ssh config in your user. each node must have an entry like this: 
 
```
Host        server-host-name
User        root
Port        6570
HostName    server-host-name.clickyab.ae
```

*NOTE:* The Host part is important! make sure its the Hostname of the node or it will fail on starting the node systemd service

### ceph_deploy

Install ceph-deploy on your local. using `pip` is ok 

```bash
pip install --upgrade ceph-deploy
```

*NOTE:* Ceph-deploy use the current dir to store the result data on your local machine. 
create an empth directory and make sure you back it up later. 
we use the ceph user home on the local machine.

## Initialize cluster (once!)

call ceph-deploy for the first node (kube-0)

```bash
ceph-deploy new kube-0
```

edit config to this :
 
```ini
[global]
fsid = 2769b63c-a321-4d31-a56b-48130beaefd3
mon_initial_members = kube-0
mon_host = 192.168.10.1
public network = 192.168.0.0/16
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx 
```

TODO : update this for any change

## Install ceph on every node

Install ceph on any new node. 
```bash
ceph-deploy install --release jewel kube-{0,1,2}
```

Also make sure the partitions needed for this task (in our setup /dev/sda4 and /dev/sdb4) formatted using `xfs`

## Install ceph monitor (only per monitor)

Monitor nodes are very important in ceph. we decide for evey 5 node to have one 
monitor node (1 mon 4 osd)

for first monitor
```bash
ceph-deploy mon create-initial
```

next monitors:

```bash
ceph-deploy mon add new-mon-node 
```

Also create a mds for any monitor node `ceph-deploy mds create kube-0`

the files in current directory are the key to use this cluster. backup them

## Install ceph admin key on nodes

This can be security risk, but its ok. 

```bash
ceph-deploy admin kube-{0,1,2} 
```

## Create osd nodes 

for first three node I use this command (sda4/sdb4 are ceph partition on each node)

```bash
ceph-deploy osd create kube-0:sda4 kube-0:sdb4 kube-1:sda4 kube-1:sdb4 kube-2:sda4 kube-2:sdb4 
```

## Activate node

After installation or after recovery of a node must activate osd like this :

```bash
ceph-deploy osd activate kube-0:sda4 kube-0:sdb4 kube-1:sda4 kube-1:sdb4 kube-2:sda4 kube-2:sdb4
```

## Setup cephfs (only once)

Make sure ceph-client installed on each node. it can be done using `ceph` or 
 package manager. ceph-deploy need access to the node and can do the task (see above)
 or simply call `apt install ceph`
 
on one node with admin keyring installed call this commands : 

*NOTE* : only once, I've done it already so do not do this again, only on new cluster.

```bash 
ceph osd pool create cephfs_data 96
ceph osd pool create cephfs_data 96
ceph fs new clickyabfs cephfs_metadata cephfs_data
```

there is a file in your `ceph-deploy` folder in local, called `ceph.client.admin.keyring`
there is a secret on that : 
```toml
[client.admin]
    key = THE_BASE64_KEY
```
this key is important and is the key to the cluster, we call it admin secret and is available in this repository
create a file with name ``,content of the `/etc/ceph/admin.secret` is the admin secret file in this example. 
in kubernetes we use secret to store this. to prevent human disaster the root file system is only mounted on
monitor nodes, NOT ALL NODES! 

for mounting one folder of this we use this command: 

*NOTE* : install `ceph-fs-common` on ubuntu
```bash 
mount -t ceph 192.168.10.1:6789:/ /cephfs -o name=admin,secretfile=/etc/ceph/admin.secret
```



Make sure `/etc/ceph/admin.secret` is installed on every node. 

On every node in cluster there is a `share` folder  

*NOTE* : I use `/etc/fstab` for mount them. I do not know if this make a problem 
when we restart the server and `ceph` master is not ready/pingable or so and if this 
 make the boot very long. so if its the case use another way to do it lazy. 

this is the line in fstab :

``` 
192.168.10.1:6789:/share /share ceph name=admin,secretfile=/etc/ceph/admin.secret,noatime,_netdev 0 2                                                                       
```

## Refs

http://docs.ceph.com/docs/master/start/quick-ceph-deploy/
http://docs.ceph.com/docs/master/start/quick-cephfs/