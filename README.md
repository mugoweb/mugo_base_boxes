# Mugo Base Boxes
**NOTE:** *this project has been significantly refactored. See the `_archived` folder for legacy configurations.*

These packer configurations allow us to build and update [Mugo's](http://mugo.ca) Vagrant development boxes. They
can be used to run existing projects or bootstrap new ones. Each variant of the base boxes is available as a standalone 
project that can be run independently.

The boxes are organized using the following folder structure:
```
<< OS >> / << PHP VERSION >> /
```
For instance, the CentOS 8 PHP 7.2 box is located at `mugo_base_boxes/centos8/php7.2/`.

Scripts automate building, provisioning, cleaning up, shrinking, and exporting the boxes.

## Usage
To build a box, simply CD into one its directory and invoke `packer` with the its configuration file. For example, to
build the CentOS 8 PHP 7.2 box:
```
cd mugo_base_boxes/centos8/php7.2/
packer build php7.2.json
```
Once the build has completed, the `mugo_base_boxes/centos8/php7.2/builds` directory will have a Vagrant box in it. There
will also be a corresponding `.json` file, to facilitate cloud-based versioned usage. These can be uploaded to [Mugo Web's google cloud storage bucket](https://console.cloud.google.com/storage/browser/mugoweb)
via a browser or the command line:  
```
gsutil cp builds/centos8-php7.2* gs://mugoweb
```

## Defaults
Based on [Hashicorp's recommendation](https://www.vagrantup.com/docs/boxes.html), all boxes are built from scratch 
using forked versions of the [Bento Box](https://github.com/chef/bento) configuration files.
 
The boxes are configured as follows:
* a `root` user with password `root`
* a `vagrant` user with password `vagrant` and passwordless `sudo`
* an `ezpub` user with password `ezpub` and passwordless `sudo`
* an entry for the vagrant insecure key in `~/.ssh/authorized_keys` for both users
* `apache` listening on port `80` and `443`
* `mysql` listening on port `3306` and with `root` password `root`
* `php-xdebug` installed and available on port `9000` but disabled by default (enable in `/etc/php.d/xdebug.ini`)
* `varnish` configured to listen on `8080` but disabled by default
* `nginx` installed but disabled by default
* `nfsd` installed and configured to share the webroot
* `firewalld` installed, enabled, and configured for the stack
* a local `dev.crt` and `dev.pem` in `/etc/ssl`
* `250G` VirtualBox primary disk (useful on larger projects -- most publicly available boxes have `40G` disks). **Note:**
that this means you will need more than `250G` disk space on the machine that you use to build the boxes
(see `scripts/common/minimize.sh` to understand why).

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
All customization should be done in ansible, by editing the `ansible/main.yml` and `ansible/host_vars/common.yml` files. If you plan to 
use packer to rebuild the vagrant box using your customizations, you should also update the packer JSON file's variables
sections (this will help generate the correct outputs by the script). So for instance, if you've made some tweaks to the
`ansible/main.yml` file and want to build a new version of the box for the team to use, you should also edit the `version`
variable in the packer configuration file so that a new version of the box is generated in the box's JSON file:
```
    "variables": {
      ...
      "version": "0.1",
      ...
    }
```

### Ansible
All roles are from [Ansible Galaxy](https://galaxy.ansible.com/) but included in this repo.