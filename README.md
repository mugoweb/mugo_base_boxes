# Mugo Base Boxes
These packer configuration files allow us to build and update [Mugo's](http://mugo.ca) Vagrant development boxes. They
can be used to run existing projects or bootstrap new ones. Currently, there are 4 variants:
* **CentOS 7.2**: PHP 5.6 / Varnish 4.1
* **CentOS 7.2**: PHP 7.2 / Varnish 6.0
* **Ubuntu 18.04**: PHP 5.6 / Varnish 4.1
* **Ubuntu 18.04**: PHP 7.2 / Varnish 6.0

Scripts automate building, provisioning, cleaning up, shrinking, and exporting the boxes.

## Usage
To build a box, simply invoke `packer` with the box's configuration file:
```
packer build ubuntu18.04.2-php7.2.json
```
After a successful build, the corresponding Vagrant box can be found in the `builds` folder. The build process also 
generates corresponding `.box` and `.json` files, which facilitate cloud-based versioned usage and can be
uploaded to [Mugo Web's google cloud storage bucket](https://console.cloud.google.com/storage/browser/mugoweb).

## Defaults
Based on [Hashicorp's recommendtation](https://www.vagrantup.com/docs/boxes.html), all boxes are built from scratch 
using forked versions of the [Bento Box](https://github.com/chef/bento) configuration files.
 
The boxes are configured as follows:
* a `root` user with password `root`
* a `vagrant` user with password `vagrant` and passwordless `sudo`
* an `ezpub` user with password `ezpub` and passwordless `sudo`
* an entry for the vagrant insecure key in `~/.ssh/authorized_keys` for both users
* `apache` listening on port `80` and `443`
* `mysql` listening on port `3306` and with `root` password `root`
* `php-xdebug` installed and available on port `9000` on the PHP 7 boxes
* `varnish` listening on port `8080`
* `nginx` installed but not listening
* `firewalld` installed, enabled, and configured for the stack
* a local `dev.crt` and `dev.key` in `/etc/ssl`
* `100G` VirtualBox primary disk (useful on larger projects -- most publicly available boxes have `40G` disks)

The boxes include the following software:
* `acl`
* `atop`
* `bash-completion`
* `byobu`
* `composer`
* `curl`
* `git`
* `htop`
* `iotop`
* `java`
* `memcached`
* `nodejs`
* `pv`
* `vim`
* `redis`
* `rsync`
* `sendmail`
* `tree`
* `unzip`
* `vim`
* [Virtual Box Guest Additions](https://docs.oracle.com/cd/E36500_01/E36502/html/qs-guest-additions.html)
* `wget`
* `zip`

The boxes include the following NPM packages installed system-wide:
 * [diff-so-fancy](https://www.npmjs.com/package/diff-so-fancy)
 * [node-sass](https://www.npmjs.com/package/node-sass)
 * [uglifycss](https://www.npmjs.com/package/uglifycss)
 * [uglify-js](https://www.npmjs.com/package/uglify-js)

The boxes include the following VIM addons:
* [eunuch](https://github.com/tpope/vim-eunuch)
* [gitgutter](https://github.com/airblade/vim-gitgutter)
* [nerdtree](https://github.com/scrooloose/nerdtree)
* [papercolor-theme](https://github.com/NLKNguyen/papercolor-theme)
* [polyglot](https://github.com/sheerun/vim-polyglot)
* [powerline](https://github.com/powerline/powerline)
* [vundle](https://github.com/VundleVim/Vundle.vim)

The CentOS boxes include the following additional repos:
 * [epel](https://fedoraproject.org/wiki/EPEL)
 * [remi](https://rpms.remirepo.net/)

The apache daemon's umask is set to `0002`, server users belong to the apache group, and the apache daemon belongs to 
the server users' groups. 
 
## Customization
### Packer
The configuration files were built with customization in mind. Simple tweaks can be made in the `variables` section 
of each script:
```
  "variables": {
    "iso_checksum": "a2cb36dc010d98ad9253ea5ad5a07fd6b409e3412c48f1860536970b073c98f5",
    "iso_checksum_type": "sha256",
    "iso_mirror": "http://cdimage.ubuntu.com",
    "iso_mirror_directory": "ubuntu/releases/18.04.2/release",
    "iso_name": "ubuntu-18.04.2-server-amd64.iso",
    "image_name": "ubuntu18.04.2",
    "local_builder_password": "packer",
    "local_builder_root_password": "root",
    "local_builder_username": "packer",
    "server_php_version": "7.2",
    "server_users_local": "[ \"ezpub\", \"vagrant\" ]",
    "server_users_stage": "[ \"ezpub\" ]",
    "server_users_prod": "[ \"ezpub\" ]",
    "server_varnish_version": "60lts",
    "version": "0.1",
    "vb_cpus": "1",
    "vb_disk_size": "102400",
    "vb_memory": "1024"
  }
```

`server_php_version` can be any [currently-supported](http://php.net/supported-versions.php) major version
(eg. `5.6`, `7.1`, `7.2`, `7.3`, etc.).

`server_varnish_version` can be any version listed on the [Varnish Cache packagecloud.io page](https://packagecloud.io/varnishcache)
(eg. `41`, `60lts`).

`server_users_local|stage|prod` should include the list of users, besides `root`, who should exist on a given 
builder (currently, only the `local` builder is configured). The default user password is the same as the username. On 
the ```local``` builder, all users will also have the 
[vagrant insecure key](https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub) added to their 
```~/.ssh/authorized_keys``` file.

The following variables are passed from packer to ansible:
* `vars_file_name` (value is derived from the `variables` section's `image_name`.yml)
* `server_users`: (value is derived from the `variables` section's `server_users_local`)
* `server_php_version`: (value is derived from the `variables` section's `server_php_version`)
* `server_varnish_version`: (value is derived from the `variables` section's `server_varnish_version`)
* `packer_builder_name`: (value is derived from the `builders` section's `name`)

To add more such variables, edit the `extra_arguments` property of the `ansible-local` provisioner (this is an escaped JSON 
string ingested by ansible):
```
"'{\"vars_file_name\":\"{{user `image_name`}}.yml\",\"server_users\":{{user `server_users_local`}},\"server_php_version\":\"{{user `server_php_version`}}\",\"server_varnish_version\":\"{{user `server_varnish_version`}}\"}'"
```

### Ansible
`ansible/host_vars/common.yml` stores all shared configuration variables; platform platform-specific YAML files in 
`ansible/host_vars` are used for overrides.

For example, to add a package that should only be downloaded on `CentOS7.6.1810`, simply add an entry to the 
`ansible/host_vars/centos7.6.1810.yml` file's `platform_specific_packages` list.

There's only a single playbook, `ansible/main.yml`, which is used for all builds.

Within `main.yml` you can selectively run tasks based on variable conditions:
```
- name: cleanup default php packages on ubuntu php 5.6 installations
  package:
    name: "php7.*"
    state: absent
  when: (server_php_version is search('[5].*')) and (os_type == "Ubuntu")
```

The same is true for roles:
```
- role: geerlingguy.nfs
  when: packer_build_name == "local"
```

Almost all roles are from [Ansible Galaxy](https://galaxy.ansible.com/) and specified in the `ansible/requirements.yml` 
file.

Sometimes, it is necessary to modify Ansible Galaxy roles. In such cases, the roles are not added to 
`ansible/requirements.yml` but are included in `ansible/roles` instead.