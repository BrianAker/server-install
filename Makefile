# vim:ft=automake

IPADDRESS = $(shell ifconfig  | grep 'inet ' | grep -v 127.0.0.1 | awk '{ print $$2 }')

default: 
ifeq (10.6.118.177,${IPADDRESS})
	sudo hostname localhost
	$(MAKE) base_openstack
else
	$(MAKE) base_install
endif
	$(MAKE) -f accounts.am tangentci
	$(MAKE) -f accounts.am lazlo
	$(MAKE) -f accounts.am secure-host
	sudo reboot

base_openstack:
	@if test -f /etc/debconf.conf; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am openstack; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am openstack; \
	  fi

base_install:
	@if test -f /etc/debconf.conf; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am; \
	  elif [ -f '/etc/SuSE-release' ]; then  \
	  	echo "Suse is not currently supported"; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am ${INSTALL_TYPE}; \
	  elif [ -f '/etc/centos-release' ]; then  \
	  	DISTRIBUTION=centos $(MAKE) -f rhel.am; \
	  elif test -f /etc/redhat-release; then \
	  	DISTRIBUTION=rhel $(MAKE) -f rhel.am; \
	  elif test -x /usr/sbin/pkg_add; then \
	  	DISTRIBUTION=freebsd9 $(MAKE) -f freebsd.am; \
	  elif test -d /etc/mach_init.d; then \
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
