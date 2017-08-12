# RBAC access control to a namespace

## Create The User Credentials

Create a private key for your user. In this example, we will name the file employee.key:
```bash
openssl genrsa -out employee.key 2048
```

Create a certificate sign request employee.csr using the private key you just created (employee.key in this example). 
Make sure you specify your username and group in the -subj section (CN is for the username and O for the group). 
we will use employee as the name and devteam as the group:

```bash
openssl req -new -key employee.key -out employee.csr -subj "/CN=employee/O=devteam"
```

the config from the master folder `/etc/kubernetes/pki` is needed to sign the key 

