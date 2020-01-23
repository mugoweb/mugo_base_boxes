#!/bin/sh -eux
# forked from https://github.com/chef/bento

dnf -y update;
reboot;
sleep 60;