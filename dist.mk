# vim:ft=automake

DEB_CONF := $(strip $(wildcard /etc/debconf.conf))
SUSE_RELEASE := $(strip $(wildcard /etc/SuSE-release))
FEDORA_RELEASE := $(strip $(wildcard /etc/fedora-release))
CENTOS_RELEASE := $(strip $(wildcard /etc/centos-release))
RHEL_RELEASE := $(strip $(wildcard /etc/redhat-release))
FREEBSD_RELEASE := $(shell test -x '/usr/sbin/pkg_add' > /dev/null 2>&1 ; echo $$?)
OSX_RELEASE := $(shell test -d '/etc/mach_init.d' > /dev/null 2>&1 ; echo $$?)

ifneq (${DEB_CONF},)
  DISTRIBUTION := ubuntu
  include $(srcdir)/ubuntu.am
  include $(srcdir)/accounts.am
else ifneq (${SUSE_RELEASE},)
  DISTRIBUTION := suse
  include zypper.am
  include $(srcdir)/accounts.am
else ifneq (${FEDORA_RELEASE},)
  DISTRIBUTION := fedora
  include fedora.am
  include $(srcdir)/accounts.am
else ifneq (${CENTOS_RELEASE},)
  DISTRIBUTION := centos
  include rhel.am
  include $(srcdir)/accounts.am
else ifneq (${RHEL_RELEASE},)
  DISTRIBUTION := rhel
  include rhel.am
  include $(srcdir)/accounts.am
else ifeq (${FREEBSD_RELEASE},0)
  DISTRIBUTION := freebsd9
  include freebsd.am
else ifeq (${OSX_RELEASE},0)
  DISTRIBUTION := osx
  include osx.am
else
  DISTRIBUTION := unknown
endif

