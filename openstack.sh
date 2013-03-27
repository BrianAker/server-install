#!/bin/bash -e

function required_software()
{
  sudo apt-get install -y git pound
}

function git_clone()
{
  git clone https://github.com/openstack-dev/devstack.git
}

function install_stack()
{
  cd devstack; ./stack.sh
}

function enable_networking()
{
  sed -i -e's/startup=0/startup=1/' /etc/default/pound
}

function init()
{
  install_git
  git_clone
  install_stack
  enable_networking
}

init
echo "complete"
