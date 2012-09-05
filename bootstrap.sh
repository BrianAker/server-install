#!/bin/bash

if [ $(uname) = "ubuntu" ];
then
  sudo apt-get install -y git make
else
  sudo yum install -y git make
fi
make

