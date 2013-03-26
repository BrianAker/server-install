# vim:ft=automake

srcdir = $(shell pwd)
IPADDRESS = $(shell /sbin/ifconfig  | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $$2 } ' | head -1)
MACADDR = $(shell /sbin/ifconfig  | grep 'ether ' | awk '{ print $2 }')
ALL_MAKEFILES := $(wildcard *.am) 
ALL_SCRIPTS := $(wildcard *.sh) 

JENKINS_SLAVES=

DEVBOX_MAC= 34:15:9e:03:20:fa f8:1e:df:e2:7e:07 0a:1e:df:e2:7e:07
DEVBOX_IP= 10.0.2.16 10.0.2.24
OPENSTACK_IP= 10.6.52.125

DIST_MAKEFILES := ubuntu.am fedora.am rhel.am freebsd.am osx.am

include $(srcdir)/dist.mk

.PHONY: all check show install base_install deploy

all: show

check:
	$(foreach each_makefile,$(DIST_MAKEFILES),$(MAKE) --warn-undefined-variables --dry-run $(each_makefile);)
	$(foreach each_file,$(ALL_SCRIPTS),bash -e -n $(each_file);)
	mac := $(foreach each_mac,$(MACADDR),$(findstring ${each_mac},${DEVBOX_MAC}))
	host_ip := $(foreach each_mac,$(IPADDRESS),$(findstring ${each_mac},${DEVBOX_IP}))
	openstack_host := $(foreach each_mac,$(IPADDRESS),$(findstring ${each_mac},${DEVBOX_IP}))

install: | show prep
ifeq (openstack_host,${IPADDRESS})
	hostname localhost
	$(MAKE) base_openstack
else
  ifneq (${mac},0)
	@echo "MATCHED MAC ADDRESS"
	@echo "DEV SERVER"
	$(MAKE) base-dev
  else
    ifneq (${host_ip},0)
	@echo "MATCHED IP ADDRESS"
	@echo "DEV SERVER"
	$(MAKE) base-dev
    else
	@echo "JENKINS SLAVE"
	$(MAKE) base_jenkins_slave
	$(MAKE) tangentci
	$(MAKE) ping-user
	$(MAKE) lazlo
	$(MAKE) secure-host
	reboot
	endif
    endif
  endif
endif

base_install:
	$(MAKE) basics
	$(MAKE) base-dev

base_openstack:
	$(MAKE) openstack

base_jenkins_slave:
	$(MAKE) build_tools

show:
	@echo "IPADDRESS ${IPADDRESS}"
	@echo "DISTRIBUTION: ${DISTRIBUTION}"

deploy:
ifdef INSTALL_SERVER
	scp bootstrap.sh "$$INSTALL_SERVER":~/
	-git remote rm "$$INSTALL_SERVER"
	git remote add "$$INSTALL_SERVER" ssh://"$$INSTALL_SERVER"/~/server-install.git
	ssh -t "$$INSTALL_SERVER" ./bootstrap.sh
endif


.DEFAULT_GOAL:= all

.NOTPARALLEL:
