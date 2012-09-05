#!/bin/bash

if [ -f "/etc/redhat-release"  ]; then
  sudo yum install -y git make
elif [ -f "/etc/debconf.conf"  ]; then
  sudo apt-get update
  sudo apt-get install -y git make
elif [ -d "/etc/mach_init.d"  ]; then
  echo "Install homebrew"
#  ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
fi

git clone https://github.com/BrianAker/server-install.git

if [ -f "/etc/debconf.conf"  ]; then
  make -f server-install/ubuntu.am
elif [ -f "/etc/redhat-release"  ]; then
  make -f server-install/fedora.am
elif [ -d "/etc/mach_init.d"  ]; then
  make -f server-install/osx.am
fi
