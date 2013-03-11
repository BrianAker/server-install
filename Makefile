# vim:ft=automake

.SHELLFLAGS= -e

IPADDRESS = $(shell ifconfig  | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $$2 }')
ALL_MAKEFILES := $(wildcard *.am) 
ALL_SCRIPTS := $(wildcard *.sh) 

.PHONY: all check

all:

check:
	echo ${ALL_MAKEFILES2}
	$(foreach each_makefile,$(ALL_MAKEFILES),$(MAKE) --warn-undefined-variables --dry-run $(each_makefile);)
	$(foreach each_file,$(ALL_MAKEFILES),bash -e -n $(each_file);)

default: 
	$(MAKE) base_install
ifeq (10.6.118.177,${IPADDRESS})
	sudo hostname localhost
	$(MAKE) base_openstack
else
	$(MAKE) base_jenkins_slave
endif
	$(MAKE) -f accounts.am tangentci
	$(MAKE) -f accounts.am lazlo
	$(MAKE) -f accounts.am secure-host
	sudo reboot

base_install:
	@if test -f '/etc/debconf.conf'; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am base; \
	  elif [ -f '/etc/SuSE-release' ]; then  \
	  	echo "Suse is not currently supported"; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am base; \
	  elif [ -f '/etc/centos-release' ]; then  \
	  	DISTRIBUTION=centos $(MAKE) -f rhel.am base; \
	  elif test -f '/etc/redhat-release'; then \
	  	DISTRIBUTION=rhel $(MAKE) -f rhel.am base; \
	  elif test -x '/usr/sbin/pkg_add'; then \
	  	DISTRIBUTION=freebsd9 $(MAKE) -f freebsd.am base; \
	  elif test -d '/etc/mach_init.d'; then \
	  	$(MAKE) -f osx.am base; \
	  fi

base_openstack:
	@if test -f '/etc/debconf.conf'; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am openstack; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am openstack; \
	  fi

base_jenkins_slave:
	@if test -f '/etc/debconf.conf'; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am; \
	  elif [ -f '/etc/SuSE-release' ]; then  \
	  	echo "Suse is not currently supported"; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am; \
	  elif [ -f '/etc/centos-release' ]; then  \
	  	DISTRIBUTION=centos $(MAKE) -f rhel.am; \
	  elif test -f '/etc/redhat-release'; then \
	  	DISTRIBUTION=rhel $(MAKE) -f rhel.am; \
	  elif test -x '/usr/sbin/pkg_add'; then \
	  	DISTRIBUTION=freebsd9 $(MAKE) -f freebsd.am; \
	  elif test -d '/etc/mach_init.d'; then \
	  	$(MAKE) -f osx.am; \
	  fi

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
