# vim:ft=automake

base_install:
	@if test -f /etc/debconf.conf; then \
	  	$(MAKE) -f ubuntu.am; \
	  elif [ -f '/etc/SuSE-release' ]; then  \
	  	echo "Suse is not currently supported"; \
	  elif [ -f '/etc/fedora-release' ]; then  \
	  	DISTRIBUTION=fedora $(MAKE) -f yum.am; \
	  elif [ -f '/etc/centos-release' ]; then  \
	  	DISTRIBUTION=centos $(MAKE) -f yum.am; \
	  elif test -f /etc/redhat-release; then \
	  	DISTRIBUTION=rhel $(MAKE) -f yum.am; \
	  elif test -d /etc/mach_init.d; then \
	  	$(MAKE) -f osx.am; \
	  fi

default: 
	$(MAKE) base_install
	$(MAKE) -f accounts.am tangentci
