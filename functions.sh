#!/bin/bash -e

function check_user()
{
  id "$1" > /dev/null 2>&1
}

function set_wheel_or_sudo()
{
  local create_user=$1

  check_user "$create_user"
  if [ $? -eq 0 ]; then
    egrep "^sudo:" /etc/group > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      eval "usermod -G sudo $create_user"
    fi

    egrep "^wheel:" /etc/group > /dev/null 2>&1
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

  check_user "$create_user"
  if [ $? -eq 0 ]; then
    local sshd_file=''
    if [[ -f "/etc/ssh/sshd_config" ]]; then
      sshd_file="/etc/ssh/sshd_config"
    elif [[ -f "/etc/sshd_config" ]]; then
      sshd_file="/etc/sshd_config"
    else
      echo "Unable to discover sshd_config file"
      return 1
    fi

    echo "egrep -c $create_user $sshd_file"
    egrep -c "^AllowUsers $create_user" $sshd_file > /dev/null
    local sshd_allowuser_check=$?

    echo "USER:$create_user $sshd_allowuser_check"

    if [ $sshd_allowuser_check -eq 1 ]; then
      local TMPOUT="$(mktemp)"
      eval "printf \"\nAllowUsers $create_user\n\" > $TMPOUT"
      eval "cat $TMPOUT >> $sshd_file"
      if [ $? -ne 0 ]; then
        echo "Error occurred while trying to append to $sshd_file"
        return 1
      fi
    fi

    egrep -c $create_user $sshd_file > /dev/null 2>&1
    sshd_allowuser_check=$?

    if [ $sshd_allowuser_check -eq 1 ]; then
      cat "$sshd_file"
      return 1
    fi
  else
    echo "USER does not exist: $create_user"
  fi

  return 0
}
