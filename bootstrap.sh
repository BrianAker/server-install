#!/bin/bash -e

function install_git_make()
{
  if [ -f "/etc/redhat-release"  ]; then
    sudo yum install -y git make
  elif [ -f "/etc/regdomain.xml"  ]; then
    pkg_add -F -r bash git gmake
  elif [ -f "/etc/debconf.conf"  ]; then
    sudo apt-get update -y
    sudo apt-get install -y git-core make
  elif [ -d "/etc/mach_init.d"  ]; then
    if [ ! -f /usr/local/bin/brew ]; then
      echo "Install homebrew"
      `ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)`
    fi
  fi
}

# If the projects.am file is around we know then that we are in the repository
function run_server_install()
{
  if [ -f 'projects.am' ]; then
    git pull
    make 'local-install'
  elif [ -d 'server-install' ]; then
    (cd 'server-install' && git pull && make 'local-install')
  else
    git clone https://github.com/BrianAker/server-install.git
    (cd 'server-install' && make 'local-install')
  fi
}

function init()
{
  install_git_make
  run_server_install
}
init
echo "Completed"
