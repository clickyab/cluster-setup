# Setup persistent storage for kubernetes
### DO NOT USE THIS - SEE THE CEPHFS VERSION ###
## Pre requirement

Make sure all nodes has required package: 

```bash
apt install ceph-fs-common ceph-common
```

Setup the pool for it, this is needed only once : 

```bash
ceph osd pool create kubernetes 64 64 
```

Make sure cluster secret is available as a secret in cluster. 
the secret is in this repo in `ceph/token`  

create a yaml file (also a version is available at kubernetes/token/ceph-rbd.yml)
contain this : 

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
data:
  key: "PUT-BASE64-OF-THE-CEPH-SECRET-HERE"
```

and use `kubectl appy -f ./the-file.yml`

## Create new volume

create a volume for your need (for example for statics) : 

```bash
rbd create statics --size 1G --pool kubernetes 
rbd ls -l kubernetes # Should show the volume
```

due to this bug [1578484](https://bugs.launchpad.net/ubuntu/+source/ceph/+bug/1578484)
disable some feature : 
 
```bash
 rbd feature disable --pool kubernetes statics exclusive-lock object-map fast-diff deep-flatten
```

Now create a new yml file for this volume: 

```yaml
apiVersion: v1
kind: PersistentVolume
metadata: 
  name: ceph-pv
spec: 
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  rbd: 
    monitors: 
      - 192.168.100.60:6789
    pool: kubernetes
    image: statics
    user: admin
    secretRef: 
      name: ceph-secret
    fsType: ext4
    readOnly: false
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: statics-claim
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

Also put it in the `kubernetes/volume` folder of this repo and simply apply it using 
`kubectl`

NOTE: persistent volumes are namespace agnostic, but the claims are not. 
every namespace must have one claim if needed. 

## Claim the volume by an pod 

Must add a volume to a pod (or a template of pod) like this : 

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: ceph-nginx-example
spec: 
  containers: 
    - name: ceph-nginx-example
      image: nginx
      ports:
        - name: statics
          containerPort: 3306
      volumeMounts: 
        - name: static-pv
          mountPath: /usr/share/nginx/html
  volumes: 
    - name: static-pv
      persistentVolumeClaim:
        claimName: statics-claim
```

NOTE : This must be in the claim namespace.


This was based on this : https://sysdig.com/blog/ceph-persistent-volume-for-kubernetes-or-openshift/