#!/bin/bash -e
#

function openstack_install()
{
  if [ -f $KEYSTONERC ]; then
    source $KEYSTONERC
  fi
  openstack_keystone
  openstack_glance_use_keystone
  openstack_cinder
  openstack_nova
  openstack_add_glance_image
}

function openstack_cinder()
{
  openstack-db --service cinder --init --rootpw ""
  mkdir -p /var/lib/cinder
  truncate --size=20G /var/lib/cinder/cinder-volumes.img
  losetup --show -f /var/lib/cinder/cinder-volumes.img
  CINDER_VOL_DEVICE=$(losetup -a | grep "/var/lib/cinder/cinder-volumes.img" | cut -d':' -f1)
  vgcreate cinder-volumes $CINDER_VOL_DEVICE
  systemctl start openstack-cinder-volume.service
  systemctl enable openstack-cinder-volume.service
}

function openstack_cinder_perm()
{
  LOOP_EXEC_DIR=/usr/libexec/cinder
  LOOP_SVC=cinder-demo-disk-image.service
  LOOP_EXEC=voladm
  GH_SYSD_BASE_URL=https://raw.github.com/openstack-fedora/openstack-configuration/master
  GH_SYSD_LOOP_SVC_URL=$GH_SYSD_BASE_URL/systemd/$LOOP_SVC
  GH_SYSD_LOOP_EXEC_URL=$GH_SYSD_BASE_URL/bin/$LOOP_EXEC
  mkdir -p $LOOP_EXEC_DIR
  curl $GH_SYSD_LOOP_SVC_URL -o /usr/lib/systemd/system/$LOOP_SVC
  curl $GH_SYSD_LOOP_EXEC_URL -o $LOOP_EXEC_DIR/$LOOP_EXEC
  chmod -R a+rx $LOOP_EXEC_DIR
  systemctl start $LOOP_SVC && systemctl enable $LOOP_SVC
  CINDER_VOL_DEVICE=/dev/loop0
  vgcreate cinder-volumes $CINDER_VOL_DEVICE
  systemctl start openstack-cinder-volume.service
  systemctl enable openstack-cinder-volume.service
}

function openstack_keystone()
{
  openstack-db --service keystone --init --rootpw ""
  openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
  systemctl start openstack-keystone.service && systemctl enable openstack-keystone.service
  ADMIN_PASSWORD=$OS_PASSWORD SERVICE_PASSWORD=servicepass openstack-keystone-sample-data
  keystone user-list
}

function openstack_nova()
{
  openstack_nova_database
  openstack_nova_use_keystone
  openstack_nova_service
  openstack_nova_network
}

function openstack_nova_service()
{
  for svc in api objectstore compute network scheduler cert; do systemctl start openstack-nova-$svc.service; done
  for svc in api objectstore compute network scheduler cert; do systemctl enable openstack-nova-$svc.service; done
  nova flavor-list
}

function openstack_nova_database()
{
  openstack-db --service nova --init --rootpw ""
  nova-manage db sync
}

function openstack_nova_use_keystone()
{
  openstack-config --set /etc/nova/api-paste.ini filter:authtoken admin_tenant_name service
  openstack-config --set /etc/nova/api-paste.ini filter:authtoken admin_user nova
  openstack-config --set /etc/nova/api-paste.ini filter:authtoken admin_password servicepass
  openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
}

function openstack_nova_network()
{
  nova-manage network create demonet 10.0.0.0/24 1 256 --bridge=demonetbr0
}


function openstack_glance_use_keystone()
{
	openstack-db --service glance --init --rootpw ""
	openstack-config --set /etc/glance/glance-api.conf paste_deploy flavor keystone
	openstack-config --set /etc/glance/glance-registry.conf paste_deploy flavor keystone
	openstack-config --set /etc/glance/glance-api-paste.ini filter:authtoken admin_tenant_name service
	openstack-config --set /etc/glance/glance-api-paste.ini filter:authtoken admin_user glance
	openstack-config --set /etc/glance/glance-api-paste.ini filter:authtoken admin_password servicepass
	openstack-config --set /etc/glance/glance-registry-paste.ini filter:authtoken admin_tenant_name service
	openstack-config --set /etc/glance/glance-registry-paste.ini filter:authtoken admin_user glance
	openstack-config --set /etc/glance/glance-registry-paste.ini filter:authtoken admin_password servicepass
	for svc in api registry; do systemctl restart openstack-glance-$svc.service; done
	glance index
      }

function openstack_add_glance_image()
{
  if [ -n "$OPENSTACK_DEFAULT_IMAGE_FILE" ]; then
    if [ ! -f "$OPENSTACK_DEFAULT_IMAGE_FILE" ]; then
      curl -o $OPENSTACK_DEFAULT_IMAGE_FILE $OPENSTACK_DEFAULT_IMAGE
    fi
  fi
  glance add name=f17-jeos is_public=true disk_format=qcow2 container_format=bare < $OPENSTACK_DEFAULT_IMAGE_FILE
  glance image-list
}

function openstack_check_instance_creation()
{
  modprobe nbd
  nova keypair-add mykey > oskey.priv
  chmod 600 oskey.priv
  nova boot myserver --flavor 2 --key_name mykey --image $(glance index | grep f17-jeos | awk '{print $1}')
  nova list
}

function openstack_dashboard()
{
  systemctl restart httpd.service && systemctl enable httpd.service
  setsebool -P httpd_can_network_connect=on
  firewall-cmd --add-port=80/tcp
}

OPENSTACK_DEFAULT_IMAGE="http://berrange.fedorapeople.org/images/2012-11-15/f17-x86_64-openstack-sda.qcow2"
OPENSTACK_DEFAULT_IMAGE_FILE="/tmp/f17-x86_64-openstack-sda.qcow2"
KEYSTONERC="$HOME/.keystonerc"

export KEYSTONERC OPENSTACK_DEFAULT_IMAGE_FILE OPENSTACK_DEFAULT_IMAGE

openstack_install
