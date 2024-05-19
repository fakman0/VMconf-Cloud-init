#!/bin/bash

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
echo 'export LANG="en_US.UTF-8"' >> /root/.bashrc
echo 'export LC_ALL="en_US.UTF-8"' >> /root/.bashrc
echo 'export LC_CTYPE="en_US.UTF-8"' >> /root/.bashrc

read -p "Ssh Port (leave blank for default 22): " tempvar_sshport
read -p "Ssh PasswordAuthentication Close:N/Open:Y (leave blank for default N):" tempvar_sshpassauth
if [ "$tempvar_sshpassauth" == N ] || [ -z "$tempvar_sshpassauth" ]; then
  if [ -z "$(cat ~/.ssh/authorized_keys)" ]; then
    echo "There is no authorized ssh-key registered to the user, if you continue you may lose your ssh access."
    read -p "Please enter ssh-key (leave blank to continue): " tempvar_sshkey
    if [ -n "$tempvar_sshkey" ]; then
      echo "$tempvar_sshkey" >> ~/.ssh/authorized_keys
    fi
  fi
fi
read -p "Hostname (leave blank for default $(hostname)): " tempvar_hostname
read -p "Reboot after done Y/N (leave blank for default Y): " tempvar_reboot
ipaddr=$(hostname -I | awk '{print $1}')

if [ -n "$tempvar_hostname" ]; then
  hostnamectl set-hostname $tempvar_hostname
fi

if [ -n "$tempvar_sshport" ]; then
  sed -i "s/.*Port .*/Port $tempvar_sshport/" "/etc/ssh/sshd_config"
  systemctl restart sshd
fi

if [ -n "$tempvar_sshpassauth" == N ] || [ -z "$tempvar_sshpassauth" ]; then
  sed -i "s/.*PasswordAuthentication .*/PasswordAuthentication no/" "/etc/ssh/sshd_config"
  systemctl restart sshd
fi

if grep -q "$ipaddr" /etc/hosts ; then
  echo "There is a different definition in /etc/hosts"
else

  sed -i '2 a\\'"$ipaddr   $tempvar_hostname" /etc/hosts
fi

timedatectl set-timezone "Europe/Istanbul"

apt update && apt upgrade -y
apt install git wget curl vim nano systemd-timesyncd -y

timedatectl set-ntp true

if [ "$tempvar_reboot" == Y ]; then
  reboot
fi
