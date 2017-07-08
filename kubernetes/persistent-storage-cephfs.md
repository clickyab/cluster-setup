# Persistent Volume CepfFS

Make sure the fs is available and ready. see the `ceph` folder to do so. 

Create a secret for a path (its optional and no its not working and I have no time to fix it, so use the admin secret :) but create folder first : 

```bash
ceph auth get-or-create client.NAME mon 'allow r' mds 'allow rw path=/PATH' osd 'allow rw pool=cephfs_data'
mkdir /ceph/PATH
```
the `mkdir` is important, you must create it in your cephfs before using it. 
for example : 
`NAME = statics` and `PATH = /statics`

Save the output of this command. 

Create this using the base64 of the key you get 
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
data:
  key: "PUT-BASE64-OF-THE-CEPH-SECRET-HERE"
```

And this is an example how to use it as a volume (skip to the volumes section) : 

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: kube-registry
  namespace: docker-registry
  labels:
    k8s-app: kube-registry-upstream
    version: v0
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  selector:
    k8s-app: kube-registry-upstream
    version: v0
  template:
    metadata:
      labels:
        k8s-app: kube-registry-upstream
        version: v0
        kubernetes.io/cluster-service: "true"
    spec:
      containers:
      - name: registry
        image: registry:2
        resources:
          limits:
            cpu: 100m
            memory: 100Mi
        env:
        - name: REGISTRY_HTTP_ADDR
          value: :5000
        - name: REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY
          value: /var/lib/registry
        volumeMounts:
        - name: image-store
          mountPath: /var/lib/registry
        ports:
        - containerPort: 5000
          name: registry
          protocol: TCP
      volumes:
      - name: image-store
        cephfs:
          monitors:
            - 192.168.100.60:6789
          user: admin
          secretRef:
            name: ceph-secret-registry
          path: "/docker-registry"
```