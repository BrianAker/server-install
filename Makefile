# vim:ft=automake

default:
	if test -f /etc/debconf.conf; then \
		make -f ubuntu.am; \
	elif test -f /etc/redhat-release; then \
		make -f fedora.am; \
	elif test -d /etc/mach_init.d; then \
		make -f osx.am; \
	fi

