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

then : 

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: pma-ingress
  namespace: global
  annotations:
    # type of authentication
    ingress.kubernetes.io/auth-type: basic
    # name of the secret that contains the user/password definitions
    ingress.kubernetes.io/auth-secret: basic-auth
    # message to display with an appropiate context why the authentication is required
    ingress.kubernetes.io/auth-realm: "Authentication Required"
spec:
  rules:
  - host: www-pma.clickyab.ae
    http:
      paths:
      - path: /
        backend:
          serviceName: pma-service
          servicePort: 9000
```