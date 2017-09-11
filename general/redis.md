# Redis

When you run redis server, please be considerate to apply bellow settings:
```bash
echo 512 > /proc/sys/net/core/somaxconn
echo "vm.overcommit_memory = 1" >> /etc/sysctl.d/99-sysctl.conf
# REBOOT system or run bellow command:
sysctl vm.overcommit_memory=1
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```

