#!/bin/sh -eux

userdel -r -f $local_builder_username
[ -f /etc/sudoers.d/99_$local_builder_username ] && rm /etc/sudoers.d/99_$local_builder_username