#!/bin/bash -e

function append_sshd_config()
{
  local create_user=$1

  local sshd_file=''
  if [[ -f "/etc/ssh/sshd_config" ]]; then
    sshd_file="/etc/ssh/sshd_config"
  elif [[ -f "/etc/sshd_config" ]]; then
    sshd_file="/etc/sshd_config"
  fi

  eval "grep -c $create_user $sshd_file > /dev/null"
  local sshd_allowuser_check=$?

  echo "USER:$create_user $sshd_allowuser_check"

  if [[ "$sshd_allowuser_check" == "1" ]]; then
    local TEMP_ALLOW_USER="$(mktemp /tmp/${create_user}.XXXXXX)"

    echo "AllowUsers $create_user" > "$TEMP_ALLOW_USER"
    cat "$TEMP_ALLOW_USER" >> "$sshd_file"
  fi
}

