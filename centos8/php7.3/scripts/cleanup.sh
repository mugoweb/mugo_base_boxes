#!/bin/sh -eux

# remove previous kernels that dnf preserved for rollback
dnf autoremove -y
dnf remove -y $(dnf repoquery --installonly --latest-limit=-1 -q)

# Clean up network interface persistence
rm -fr /etc/udev/rules.d/70-persistent-net.rules;
mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
rm -fr /lib/udev/rules.d/75-persistent-net-generator.rules;
rm -fr /dev/.udev/;

for ndev in `ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "`basename $ndev`" != "ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev";
        sed -i '/^UUID/d' "$ndev";
    fi
done

# truncate any logs that have built up during the install
find /var/log -type f -exec truncate --size=0 {} \;

dnf -y clean all;

# remove the install log
rm -f /root/anaconda-ks.cfg

# remove the contents of /tmp and /var/tmp
rm -fr /tmp/* /var/tmp/*

# Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
truncate -s 0 /etc/machine-id

# clear the history so our install isn't there
[ -f /root/.bash_history ] && rm /root/.bash_history
rm -f /root/.wget-hsts
rm -f /root/original-ks.cfg
unset HISTFILE