#!/bin/bash -e

function set_wheel_or_sudo()
{
  local create_user=$1

  id "$create_user"
  if [ $? -eq 0 ]; then
    egrep "^sudo:" /etc/group
    if [ $? -eq 0 ]; then
      eval "usermod -G sudo $create_user"
    fi

    egrep "^wheel:" /etc/group
    if [ $? -eq 0 ]; then
      eval "usermod -G wheel $create_user"
    fi
  else
    echo "USER does not exist: $create_user"
  fi

  return 0
}

function append_sshd_config()
{
  local create_user=$1

  id "$create_user"
  if [ $? -eq 0 ]; then
    local sshd_file=''
    if [[ -f "/etc/ssh/sshd_config" ]]; then
      sshd_file="/etc/ssh/sshd_config"
    elif [[ -f "/etc/sshd_config" ]]; then
      sshd_file="/etc/sshd_config"
    fi

    egrep -c $create_user $sshd_file
    local sshd_allowuser_check=$?

    echo "USER:$create_user $sshd_allowuser_check"

    if [ $sshd_allowuser_check -eq 0 ]; then
      echo "\nAllowUsers $create_user" >> "$sshd_file"
    fi

    egrep -c $create_user $sshd_file
    sshd_allowuser_check=$?

    if [ $sshd_allowuser_check -eq 0 ]; then
      cat "$sshd_file"
      return 1
    fi
  else
    echo "USER does not exist: $create_user"
  fi

  return 0
}
