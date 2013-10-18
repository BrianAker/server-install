#!/bin/bash -e

function install_git_make()
{
  if [ -f "/etc/yum.conf"  ]; then
    $__SUDO yum install -y git make tar
  elif [ -f "/etc/regdomain.xml"  ]; then
    pkg_add -F -r bash git gmake
  elif [ -f "/etc/apt/sources.list"  ]; then
    if [ ! -x "/usr/bin/sudo"  ]; then
      apt-get update -y
      apt-get install -y sudo
    else
      $__SUDO apt-get update -y
    fi
    $__SUDO apt-get install -y git-core make tar
  elif [ -d "/etc/mach_init.d"  ]; then
    # Brew will not run under sudo
    __SUDO=
    if [ ! -x /usr/local/bin/brew ]; then
      echo "Install homebrew"
      `ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)`
    fi
  fi
}

# If the projects.am file is around we know then that we are in the repository
function run_server_install()
{
  if [ -f 'projects.am' ]; then
    echo "Using existing project.am"
    git pull
    $__SUDO make "$DEFAULT_INSTALL"
  elif [ -d 'server-install.git' ]; then
    echo "Using existing server-install.git"
    rm -r -f 'server-install'
    (cd 'server-install.git' && git pull)
    (git clone 'server-install.git' && cd 'server-install' &&  $__SUDO make "$DEFAULT_INSTALL")
  elif [ -d 'server-install' ]; then
    (cd 'server-install' && git pull &&  $__SUDO make "$DEFAULT_INSTALL")
  else
    git clone https://github.com/BrianAker/server-install.git
    (cd 'server-install' &&  $__SUDO make "$DEFAULT_INSTALL")
  fi
}

function init()
{
  export DEBIAN_FRONTEND=noninteractive
  export DEFAULT_INSTALL='localhost'
  export __SUDO='sudo'
  install_git_make
  run_server_install
}
init
echo "Completed"
