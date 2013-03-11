# vim:ft=automake

srcdir = $(shell pwd)
IPADDRESS = $(shell ifconfig  | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $$2 }')
ALL_MAKEFILES := $(wildcard *.am) 
ALL_SCRIPTS := $(wildcard *.sh) 

DEB_CONF := $(strip $(wildcard /etc/debconf.conf))
SUSE_RELEASE := $(strip $(wildcard /etc/SuSE-release))
FEDORA_RELEASE := $(strip $(wildcard /etc/fedora-release))
CENTOS_RELEASE := $(strip $(wildcard /etc/centos-release))
RHEL_RELEASE := $(strip $(wildcard /etc/redhat-release))
FREEBSD_RELEASE := $(shell test -x '/usr/sbin/pkg_add' > /dev/null 2>&1 ; echo $$?)
OSX_RELEASE := $(shell test -d '/etc/mach_init.d' > /dev/null 2>&1 ; echo $$?)

DIST_MAKEFILES := ubuntu.am fedora.am rhel.am freebsd.am osx.am

ifneq (${DEB_CONF},)
  include ubuntu.am
  DEBIAN_FRONTEND := noninteractive
else ifneq (${SUSE_RELEASE},)
  @echo "Suse is not currently supported"
else ifneq (${FEDORA_RELEASE},)
  DISTRIBUTION := fedora
  include fedora.am
else ifneq (${CENTOS_RELEASE},)
  DISTRIBUTION := centos
  include rhel.am
else ifneq (${RHEL_RELEASE},)
  DISTRIBUTION := rhel
  include rhel.am
else ifeq (${FREEBSD_RELEASE},0)
  DISTRIBUTION := freebsd9
  include freebsd.am
else ifeq (${OSX_RELEASE},0)
  DISTRIBUTION := osx
  include osx.am
else
  DISTRIBUTION := unknown
endif

.PHONY: all check

all:
	@echo "DISTRIBUTION: ${DISTRIBUTION}"

check:
	$(foreach each_makefile,$(DIST_MAKEFILES),$(MAKE) --warn-undefined-variables --dry-run $(each_makefile);)
	$(foreach each_file,$(ALL_SCRIPTS),bash -e -n $(each_file);)

default: | show-address base_install
ifeq (10.6.52.125,${IPADDRESS})
	sudo hostname localhost
	$(MAKE) base_openstack
else
	$(MAKE) base_jenkins_slave
	$(MAKE) tangentci
endif
	$(MAKE) lazlo
	$(MAKE) secure-host
	sudo reboot

base_install:
	$(MAKE) basics

base_openstack:
	$(MAKE) openstack

base_jenkins_slave:
	$(MAKE) build_tools

.PHONY: show-address
show-address:
	@echo ${IPADDRESS}

install:
ifdef INSTALL_SERVER
	scp bootstrap.sh "$$INSTALL_SERVER":~/
	ssh -t "$$INSTALL_SERVER" ./bootstrap.sh
endif

.DEFAULT_GOAL:= all

.NOTPARALLEL:
