#!/bin/bash -e

function install_git_make()
{
  if [ -f "/etc/yum.conf"  ]; then
    sudo yum install -y git make
  elif [ -f "/etc/regdomain.xml"  ]; then
    pkg_add -F -r bash git gmake
  elif [ -f "/etc/apt/sources.list"  ]; then
    if [ ! -x "/usr/bin/sudo"  ]; then
      apt-get update -y
      apt-get install -y sudo
    else
      sudo apt-get update -y
    fi
    sudo apt-get install -y git-core make sudo
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
    git pull
    $(__SUDO) make "$DEFAULT_INSTALL"
  elif [ -d 'server-install.git' ]; then
    (git clone 'server-install.git' && cd 'server-install' &&  $(__SUDO) make "$DEFAULT_INSTALL")
  elif [ -d 'server-install' ]; then
    (cd 'server-install' && git pull &&  $(__SUDO) make "$DEFAULT_INSTALL")
  else
    git clone https://github.com/BrianAker/server-install.git
    (cd 'server-install' &&  $(__SUDO) make "$DEFAULT_INSTALL")
  fi
}

function init()
{
  export DEFAULT_INSTALL='install-jenkins-slave'
  __SUDO=`sudo`
  install_git_make
  run_server_install
}
init
echo "Completed"
