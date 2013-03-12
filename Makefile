# vim:ft=automake

srcdir = $(shell pwd)
IPADDRESS = $(shell ifconfig  | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $$2 }')
ALL_MAKEFILES := $(wildcard *.am) 
ALL_SCRIPTS := $(wildcard *.sh) 

DIST_MAKEFILES := ubuntu.am fedora.am rhel.am freebsd.am osx.am

include $(srcdir)/dist.mk

.PHONY: all check show install base_install

all: show

check:
	$(foreach each_makefile,$(DIST_MAKEFILES),$(MAKE) --warn-undefined-variables --dry-run $(each_makefile);)
	$(foreach each_file,$(ALL_SCRIPTS),bash -e -n $(each_file);)

local-install: | show base_install
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

show:
	@echo "IPADDRESS ${IPADDRESS}"
	@echo "DISTRIBUTION: ${DISTRIBUTION}"

install:
ifdef INSTALL_SERVER
	scp bootstrap.sh "$$INSTALL_SERVER":~/
	ssh -t "$$INSTALL_SERVER" ./bootstrap.sh
endif

.DEFAULT_GOAL:= all

.NOTPARALLEL:
