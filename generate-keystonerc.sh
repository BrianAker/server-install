#!/bin/bash

function keystonerc()
{
  if [ -f "$KEYSTONERC" ]; then
    echo "$KEYSTONERC already exists"
    return 1
  else
    echo $KEYSTONERC
cat > $KEYSTONERC << _EOF
export ADMIN_TOKEN=$(openssl rand -hex 10)
export OS_USERNAME=admin
export OS_PASSWORD=verybadpass
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://127.0.0.1:5000/v2.0/
export SERVICE_ENDPOINT=http://127.0.0.1:35357/v2.0/
export SERVICE_TOKEN=\$ADMIN_TOKEN
_EOF
fi
}

if [ -z "$KEYSTONERC" ]; then
  export KEYSTONERC="$HOME/.keystonerc"
fi

keystonerc
