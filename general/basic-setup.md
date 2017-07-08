## Disable IPv6 for apt command:
Run this command:
```
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4
```

## Upgrade the whole system.
Run bellow commands onw after the others:
```
apt-get update
apt-get upgarde
```

## Remove unused kernel files:
```
apt-get autoremove --pure
```

## Update GRUB:
```
update-grab
```

## Set hostname:
```
hostnamectl set-hostname __hostname__
```

## Add hostname to /etc/hosts file:
```
echo "__hostname__" >> /etc/hostname
```

## Add manually hostname to cloudflare
## Change hostname manually in OVH panele.
