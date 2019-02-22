#!/bin/bash

if [ $packer_build_name != "local" ]; then
    exit 0
fi

checksum=$(<../../builds/$image_name-php$server_php_version-v$version.checksum)
destdir=../../builds/$image_name-php$server_php_version.json

json="{
  \"name\": \"mugo-$image_name-php$server_php_version\",
  \"description\": \"This box contains a PHP $server_php_version LAMP stack based on $image_name\",
  \"versions\": [{
    \"version\": \"$version\",
    \"providers\": [{
      \"name\": \"virtualbox\",
      \"url\": \"https://storage.googleapis.com/mugoweb/$image_name-php$server_php_version-v$version.box\",
      \"checksum_type\": \"sha1\",
      \"checksum\": \"$checksum\"
    }]
  }]
}"

echo "$json" > "$destdir"
exit 0