# vim:ft=automake

base_install:
	@if test -f /etc/debconf.conf; then \
	  $(MAKE) -f ubuntu.am; \
	  elif test -f /etc/redhat-release; then \
	  $(MAKE) -f fedora.am; \
	  elif test -d /etc/mach_init.d; then \
	  $(MAKE) -f osx.am; \
	  fi

default: base_install
	$(MAKE) -f accounts.am tangentci
