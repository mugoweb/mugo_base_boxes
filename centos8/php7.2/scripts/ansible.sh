#!/bin/bash -eux

# Install the CentOS 7 EPEL repository
yum -y install epel-release

# Install Ansible
yum -y install ansible