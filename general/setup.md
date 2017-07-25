# Pre requirement

## Disable IPv6 for apt command:
Run this command:
```
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4
```

## Upgrade the whole system.
Run bellow commands onw after the others:
```
apt-get update
apt-get upgrade
```

## Remove unused packages and kernel files:
```
apt-get autoremove --purge
```

## Update GRUB:
```
update-grub
```

## Set hostname:
```
hostnamectl set-hostname <hostname>
```

## Add hostname to /etc/hosts file:
```
echo "<hostname>" >> /etc/hostname
```

## Add manually hostname to cloudflare
## Change hostname manually in OVH panel.

## Install needed packegs:
```
apt-get update
apt-get install emacs24-nox ufw htop ntp iotop
```
## Change ssh port from default (22) to ClickYab standard (6570):
```
sed 's/Port 22/Port 6570/g' /etc/ssh/sshd_config > /tmp/sshd_config
mv /tmp/sshd_config /etc/ssh/sshd_config
systemctl restart ssh
```

## Config internal network:
```
# find second network interface name:
ip addr show
# set an ip address:
ip addr add <ip address>/<subnet mask> dev <interface name>
# up interface:
ip link up dev <interface name>
```
### Transfer network settings to /etc/network/interfaces for next restarts!
```
auto <interface name>
iface <interface name> inet static
    address <ip address>
    netmask 255.255.255.0
    broadcast 192.168.100.255
```

## Set __open file limit__ to 1024000:
```
sed 's/# End of file/* soft nofile 1024000\n* hard nofile 1024000\n* soft nproc 10240\n* hard nproc 10240\n\n# End of file\n/g' /etc/security/limits.conf > /tmp/limits.conf.new
mv /tmp/limits.conf.new /etc/security/limits.conf
echo "session required pam_limits.so" >> /etc/pam.d/common-session
```

## decrease swappiness option:
```
sysctl vm.swappiness=1
echo -e "# Edited by vahit to decrease swap usage\nvm.swappiness = 1" > /etc/sysctl.d/10-swappiness.conf # for next reboots
```

## drop memory caches everyday once:
```bash
echo "sync && echo 3 > /proc/sys/vm/drop_caches" > /etc/cron.daily/drop_caches
chmod +x /etc/cron.daily/drop_caches
echo -e "## Run daily scripts on 00:00\n0 0 * * * /etc/cron.daily/drop_caches >> /var/spool/cron/crontabs/root
```

## sync date and time hourly 
###from `kube-0 (192.168.10.1)` node, we use as **randomly** minute!!
```bash
random_min=$(( $RANDOM % 60 ))
echo -e "## sync time and date from kube-0 node\n${random_min} * * * * ntpdate 192.168.10.1" >> /var/spool/cron/crontabs/root
```

