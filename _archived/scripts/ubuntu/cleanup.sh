#!/bin/bash -eux
# forked from https://github.com/chef/bento

if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi

# Delete all Linux headers
dpkg --list \
  | awk '{ print $2 }' \
  | grep 'linux-headers' \
  | xargs apt-get -y purge;

# Delete specific Linux kernels, such as linux-image-3.11.0-15-generic but keep the current kernel virtual packages
dpkg --list \
    | awk '{ print $2 }' \
    | grep 'linux-image-.*-generic' \
    | grep -v `uname -r` \
    | xargs apt-get -y purge;

# Delete Linux source
dpkg --list \
    | awk '{ print $2 }' \
    | grep linux-source \
    | xargs apt-get -y purge;

# Delete development packages
dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-dev$' \
    | xargs apt-get -y purge;

# Delete docs packages
dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-doc$' \
    | xargs apt-get -y purge;

# Delete X11 libraries
# apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6;

# Delete obsolete networking
apt-get -y purge ppp pppconfig pppoeconf;

# Delete oddities
apt-get -y purge popularity-contest installation-report command-not-found command-not-found-data friendly-recovery bash-completion fonts-ubuntu-font-family-console laptop-detect;

# Delete Ansible
apt-get -y remove --purge ansible
apt-add-repository --remove ppa:ansible/ansible

# Exlude the files we don't need w/o uninstalling linux-firmware
echo "==> Setup dpkg excludes for linux-firmware"
cat <<_EOF_ | cat >> /etc/dpkg/dpkg.cfg.d/excludes
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
_EOF_

# Delete the massive firmware packages
rm -rf /lib/firmware/*
rm -rf /usr/share/doc/linux-firmware/*

apt-get -y autoremove;
apt-get -y clean;

# Delete docs
rm -rf /usr/share/doc/*

# Delete caches
find /var/cache -type f -exec rm -rf {} \;

# Delete cached interfaces
[ -f /etc/udev/rules.d/70-persistent-net.rules ] && rm -f /etc/udev/rules.d/70-persistent-net.rules

# Delete bash history
unset HISTFILE
rm -f $HOME/.bash_history
[ -f /root/.bash_history ] && rm /root/.bash_history
[ -f /home/vagrant/.bash_history ] && rm /home/vagrant/.bash_history

# Delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

# Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
truncate -s 0 /etc/machine-id
