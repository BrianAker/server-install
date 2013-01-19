# vim:ft=automake

default: 
	$(MAKE) base_install
	$(MAKE) -f accounts.am tangentci
	$(MAKE) -f accounts.am secure-host
	sudo reboot

base_install:
	@if test -f /etc/debconf.conf; then \
	  	DEBIAN_FRONTEND=noninteractive $(MAKE) -f ubuntu.am; \
	  elif [ -f '/etc/SuSE-release' ]; then  \
	  	echo "Suse is not currently supported"; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f fedora.am; \
	  elif [ -f '/etc/centos-release' ]; then  \
	  	DISTRIBUTION=centos $(MAKE) -f rhel.am; \
	  elif test -f /etc/redhat-release; then \
	  	DISTRIBUTION=rhel $(MAKE) -f rhel.am; \
	  elif test -x /usr/sbin/pkg_add; then \
	  	DISTRIBUTION=freebsd9 $(MAKE) -f freebsd.am; \
	  elif test -d /etc/mach_init.d; then \
	  	$(MAKE) -f osx.am; \
	  fi

install:
	scp bootstrap.sh "$$INSTALL_SERVER":~/
	ssh -t "$$INSTALL_SERVER" ./bootstrap.sh
