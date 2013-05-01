# vim:ft=automake
#

.SUFFIXES:

PKG_INSTALLER=
PKG_UPDATE=
PKG_UPGRADE=
PKG_SEARCH_INSTALL= $(PKG_INSTALLER) $(1)
BASE_INSTALL_PATH= /usr/

srcdir= $(shell pwd)/
MACADDR= $(shell sh -c "/sbin/ifconfig  | grep 'ether ' | awk '{ print $2 }'")
IPADDRESS:= $(shell /sbin/ifconfig  | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $$2 }' | head -1)
HOSTNAME:= `hostname`
HOST_TYPE:= `hostname | cut -d'-' -f1`
HOST_UUID:= `hostname | cut -d'-' -f2`
ALL_MAKEFILES:= $(wildcard *.am) 
ALL_SCRIPTS:= $(wildcard *.sh) 

JENKINS_SLAVES=

USER_EXISTS := $(shell id $(CREATE_USER) > /dev/null 2>&1 ; echo $$?)

DIST_MAKEFILES := ubuntu.am fedora.am rhel.am freebsd.am osx.am

include $(srcdir)dist.mk

.PHONY: all show check install base_install deploy

all: show

check:
	$(foreach each_makefile,$(DIST_MAKEFILES),$(MAKE) --warn-undefined-variables --dry-run $(each_makefile);)
	$(foreach each_file,$(ALL_SCRIPTS),bash -e -n $(each_file);)

install-jenkins-slave: install ci-server-update
	@echo "JENKINS SLAVE"
	$(MAKE) base_jenkins_slave
	$(MAKE) tangentci
	$(MAKE) ping-user
	$(MAKE) lazlo
	$(MAKE) secure-host
	reboot

install: | show prep base-dev

base_openstack:
	$(MAKE) openstack

base_jenkins_slave: | java

show:
	@echo "HOSTNAME ${HOSTNAME}"
	@echo "HOST_TYPE ${HOST_TYPE}"
	@echo "HOST_UUID ${HOST_UUID}"
	@echo "IPADDRESS ${IPADDRESS}"
	@echo "MACADDR ${MACADDR}"
	@echo "DISTRIBUTION: ${DISTRIBUTION}"

deploy:
ifndef INSTALL_SERVER
	@echo "INSTALL_SERVER was not set"
endif
ifdef INSTALL_SERVER
	scp bootstrap.sh "$$INSTALL_SERVER":~/
	-git remote rm "$$INSTALL_SERVER"
	git remote add "$$INSTALL_SERVER" ssh://"$$INSTALL_SERVER"/~/server-install.git
	ssh -o "RequestTTY yes" -t "$$INSTALL_SERVER" ./bootstrap.sh
endif


.DEFAULT_GOAL:= all

.NOTPARALLEL:
