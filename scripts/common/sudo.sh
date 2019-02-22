#!/bin/sh -eux

sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers;

# Set up password-less sudo for the packer user
echo "$local_builder_username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_$local_builder_username;
chmod 440 /etc/sudoers.d/99_$local_builder_username;