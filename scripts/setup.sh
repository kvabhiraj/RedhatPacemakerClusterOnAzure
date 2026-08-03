#!/bin/bash

# Enable password authentication
/usr/bin/echo "ClientAliveInterval 600" | /usr/bin/tee -a /etc/ssh/sshd_config
/usr/bin/echo "ClientAliveCountMax 10" | /usr/bin/tee -a /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd

# Enable epel & RHEL-HA repository
/usr/bin/dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
/usr/bin/dnf --config='https://rhelimage.blob.core.windows.net/repositories/rhui-microsoft-azure-rhel8-base-ha.config' install rhui-azure-rhel8-base-ha -y

/usr/bin/dnf clean all
/usr/bin/dnf repolist


# Network Static IP configuration
DEV=$(/usr/bin/nmcli con show|egrep -v "loopback|DEVICE"|awk '{print $5}')
IP=$(/usr/sbin/ip a|grep -i inet|grep $DEV|awk '{print $2}')
GW=$(/usr/bin/netstat -nr| awk '{print $2}' |egrep -v "IP|Gateway|0.0.0.0"|/usr/bin/uniq)
DNS=$(/usr/bin/cat /etc/resolv.conf |grep nameserver|awk '{print $2}')

/usr/bin/nmcli connection modify "System eth0" connection.id "eth0"
/usr/bin/nmcli connection modify "$DEV" ipv6.method disabled
/usr/bin/nmcli connection down "$DEV";/usr/bin/nmcli connection up "$DEV"

/usr/bin/nmcli connection modify "$DEV" ipv4.addresses "$IP" ipv4.method manual
/usr/bin/nmcli connection modify "$DEV" ipv4.gateway "$GW"
/usr/bin/nmcli connection modify "$DEV" ipv4.dns "$DNS"
/usr/bin/nmcli connection up "$DEV"

