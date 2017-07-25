#!/usr/bin/env bash
set -x
set -eo pipefail

echo "Run this only on bare system! never run it on production server!"
echo "There is not much verify on your input, so please! be warned"
echo "What is the internal device name? (default is eth1):"
read dev
dev=${dev:-eth1}
echo "The IP address, in range 192.168.0.0/16 for kube cluster use 192.168.10.X:"
read ip
echo "The hostname, just the first part for example kube-0 for kube-0.clickyab.ae"
read host
echo "Install cluster tools? (y|N)"
read cluster

out_ip=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

echo -e "We collect this information. if they are not correct, please start over!\n"
echo -e "eth0 IP => ${out_ip}\n"
echo -e "${dev} IP => ${ip}\n"
echo -e "hostname => ${host}.clickyab.ae\n"
echo "Press enter if anything is correct"

read dummy

echo -e "Disable IPv6 on apt\n"
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

iptables -F
iptables -X
iptables --policy FORWARD ACCEPT

echo -e "Update system"
apt-get update
apt-get upgrade
apt-get install -y emacs24-nox ufw htop ntp iotop apt-transport-https software-properties-common \
    ca-certificates curl nano

if [ "$cluster" == "y" ]; then
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce kubelet kubeadm
fi;

apt-get autoremove --purge
update-grub

hostnamectl set-hostname "${host}.clickyab.ae"
echo "${host}.clickyab.ae" > /etc/hostname

echo "Not setting the /etc/host but adding a comment. if anything is ok uncomment it"
echo "# ${out_ip} ${host}.clickyab.ae ${host}" >> /etc/host

sed 's/Port 22/Port 6570/g' /etc/ssh/sshd_config > /tmp/sshd_config
mv /tmp/sshd_config /etc/ssh/sshd_config
systemctl restart ssh

ip addr add ${ip}/16 dev ${dev}
ip link set dev ${dev} up

echo "auto ${dev}
iface ${dev} inet static
    address ${ip}
    netmask 255.255.0.0
    broadcast 192.168.255.255" >> /etc/network/interfaces

sed 's/# End of file/* soft nofile 1024000\n* hard nofile 1024000\n* soft nproc 10240\n* hard nproc 10240\n\n# End of file\n/g' /etc/security/limits.conf > /tmp/limits.conf.new
mv /tmp/limits.conf.new /etc/security/limits.conf
echo "session required pam_limits.so" >> /etc/pam.d/common-session

sysctl vm.swappiness=1
echo -e "# Set swappiness in /etc/sysctl.d/10-swappiness.conf\nvm.swappiness = 1" > /etc/sysctl.d/10-swappiness.conf # for next reboots

random_min=$(( $RANDOM % 60 ))
echo "${random_min} * * * * ntpdate 192.168.10.1" >> /var/spool/cron/crontabs/root

echo 'sync && echo 3 > /proc/sys/vm/drop_caches' > /etc/cron.daily/drop_caches
chmod +x /etc/cron.daily/drop_caches
echo -e "## Run daily scripts on 00:00\n0 0 * * * /etc/cron.daily/drop_caches" >> /var/spool/cron/crontabs/root
