#!/bin/bash

read -p "ssh port (leave blank for default "22"): " tempvar_sshport
read -p "hostname (leave blank for default $(hostname)): " tempvar_hostname
ipaddr=$(hostname -I | awk '{print $1}')

apt update && apt upgrade -y
apt install git wget curl vim nano systemd-timesyncd -y

if [ $tempvar_hostname ]; then
  hostnamectl set-hostname $tempvar_hostname
fi

if [ $tempvar_sshport]; then
  sed -i "s/.*Port .*/Port $tempvar_sshport/" "/etc/ssh/sshd_config"
  systemctl restart sshd
fi

if grep -q $ipaddr /etc/hosts ; then
  echo "There is a different definition in /etc/hosts"
else
  sed -i '2 a\'"$ipaddr   $tempvar_hostname" /etc/hosts
fi

timedatectl set-timezone "Europe/Istanbul"
timedatectl set-ntp true

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
echo 'export LANG="en_US.UTF-8"' >> /root/.bashrc
echo 'export LC_ALL="en_US.UTF-8"' >> /root/.bashrc
echo 'export LC_CTYPE="en_US.UTF-8"' >> /root/.bashrc


