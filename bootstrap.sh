#!/bin/bash

if [ -f "/etc/redhat-release"  ]; then
  sudo apt-get install -y git make
  make -f ubuntu.am
elif [ -f "/etc/redhat-release"  ]; then
  sudo yum install -y git make
  make -f fedora.am
elif [ -d "/etc/mach_init.d"  ]; then
  ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
  make -f osx.am
fi
