# vim:ft=automake

DEB_CONF := $(strip $(wildcard /etc/debconf.conf))
SUSE_RELEASE := $(strip $(wildcard /etc/SuSE-release))
FEDORA_RELEASE := $(strip $(wildcard /etc/fedora-release))
CENTOS_RELEASE := $(strip $(wildcard /etc/centos-release))
RHEL_RELEASE := $(strip $(wildcard /etc/redhat-release))
FREEBSD_RELEASE := $(shell test -x '/usr/sbin/pkg_add' > /dev/null 2>&1 ; echo $$?)
OSX_RELEASE := $(shell test -d '/etc/mach_init.d' > /dev/null 2>&1 ; echo $$?)

ifneq (${DEB_CONF},)
  DEB_CONF:= 1
  DISTRIBUTION := ubuntu
  include $(srcdir)/apt.am
  include $(srcdir)/ubuntu.am
  include $(srcdir)/accounts.am
else ifneq (${SUSE_RELEASE},)
  SUSE_RELEASE:= 1
  DISTRIBUTION := suse
  include zypper.am
  include $(srcdir)/accounts.am
else ifneq (${FEDORA_RELEASE},)
  FEDORA_RELEASE:= 1
  DISTRIBUTION := fedora
  include $(srcdir)/yum.mk
  include $(srcdir)/fedora.am
  include $(srcdir)/accounts.am
else ifneq (${CENTOS_RELEASE},)
  CENTOS_RELEASE:= 1
  DISTRIBUTION := centos
  include $(srcdir)/yum.am
  include $(srcdir)/centos.mk
  include $(srcdir)/accounts.am
else ifneq (${RHEL_RELEASE},)
  RHEL_RELEASE:= 1
  DISTRIBUTION := rhel
  include $(srcdir)/yum.am
  include $(srcdir)/centos.mk
  include $(srcdir)/accounts.am
else ifeq (${FREEBSD_RELEASE},0)
  FREEBSD_RELEASE:= 1
  DISTRIBUTION := freebsd9
  include $(srcdir)/freebsd.am
else ifeq (${OSX_RELEASE},0)
  OSX_RELEASE:= 1
  DISTRIBUTION := osx
  include $(srcdir)/osx.am
else
  DISTRIBUTION := unknown
endif

