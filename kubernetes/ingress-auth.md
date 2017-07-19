# How to protect ingress with basic auth

## Create password file

```bash
$ htpasswd -c auth foo
New password: <bar>
New password:
Re-type new password:
Adding password for user foo
```

```bash
kubectl -n TARGET-NAMESPACE create secret generic basic-auth --from-file=auth
```