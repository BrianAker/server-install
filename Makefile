# vim:ft=automake

IPADDRESS = $(shell ifconfig  | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $$2 }')
ALL_MAKEFILES := $(wildcard *.am) 
ALL_SCRIPTS := $(wildcard *.sh) 

.PHONY: all check

all:

check:
	$(foreach each_makefile,$(ALL_MAKEFILES),$(MAKE) --warn-undefined-variables --dry-run $(each_makefile);)
	$(foreach each_file,$(ALL_SCRIPTS),bash -e -n $(each_file);)

default: | show-address base_install
ifeq (10.6.118.177,${IPADDRESS})
	sudo hostname localhost
	$(MAKE) base_openstack
else
	$(MAKE) base_jenkins_slave
	$(MAKE) -f accounts.am tangentci
endif
	$(MAKE) -f accounts.am lazlo
	$(MAKE) -f accounts.am secure-host
	sudo reboot

base_install:
	@if test -f '/etc/debconf.conf'; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am basics; \
	  elif [ -f '/etc/SuSE-release' ]; then  \
	  	echo "Suse is not currently supported"; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am basics; \
	  elif [ -f '/etc/centos-release' ]; then  \
	  	DISTRIBUTION=centos $(MAKE) -f rhel.am basics; \
	  elif test -f '/etc/redhat-release'; then \
	  	DISTRIBUTION=rhel $(MAKE) -f rhel.am basics; \
	  elif test -x '/usr/sbin/pkg_add'; then \
	  	DISTRIBUTION=freebsd9 $(MAKE) -f freebsd.am basics; \
	  elif test -d '/etc/mach_init.d'; then \
	  	$(MAKE) -f osx.am basics; \
	  fi

base_openstack:
	@if test -f '/etc/debconf.conf'; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am openstack; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am openstack; \
	  fi

base_jenkins_slave:
	@if test -f '/etc/debconf.conf'; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am build_tools; \
	  elif [ -f '/etc/SuSE-release' ]; then  \
	  	echo "Suse is not currently supported"; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am build_tools; \
	  elif [ -f '/etc/centos-release' ]; then  \
	  	DISTRIBUTION=centos $(MAKE) -f rhel.am build_tools; \
	  elif test -f '/etc/redhat-release'; then \
	  	DISTRIBUTION=rhel $(MAKE) -f rhel.am build_tools; \
	  elif test -x '/usr/sbin/pkg_add'; then \
	  	DISTRIBUTION=freebsd9 $(MAKE) -f freebsd.am build_tools; \
	  elif test -d '/etc/mach_init.d'; then \
	  	$(MAKE) -f osx.am build_essential; \
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
