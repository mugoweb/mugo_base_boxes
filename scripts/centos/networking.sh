#!/bin/sh -eux
# forked from https://github.com/chef/bento

# Fix slow DNS:
# Add 'single-request-reopen' so it is included when /etc/resolv.conf is
# generated
# https://access.redhat.com/site/solutions/58625 (subscription required)
echo 'RES_OPTIONS="single-request-reopen"' >>/etc/sysconfig/network;
service network restart;
echo 'Slow DNS fix applied (single-request-reopen)';
