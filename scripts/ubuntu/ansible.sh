#!/bin/bash -eux

if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi

# Install Ansible repository
apt -y install software-properties-common
apt-add-repository ppa:ansible/ansible

# Install Ansible
apt -y update
apt -y install ansible