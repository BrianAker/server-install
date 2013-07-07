# vim:ft=automake

DEB_CONF:= $(shell test ! -f '/etc/debconf.conf' > /dev/null 2>&1 ; echo $$?)
SUSE_RELEASE:= $(shell test ! -f '/etc/SuSE-release' > /dev/null 2>&1 ; echo $$?)
FEDORA_RELEASE:= $(shell test ! -f '/etc/fedora-release' > /dev/null 2>&1 ; echo $$?)
CENTOS_RELEASE:= $(shell test ! -f '/etc/centos-release' > /dev/null 2>&1 ; echo $$?)
RHEL_RELEASE:= $(shell test ! -f '/etc/redhat-release' > /dev/null 2>&1 ; echo $$?)
FREEBSD_RELEASE := $(shell test ! -x '/usr/sbin/pkg_add' > /dev/null 2>&1 ; echo $$?)
OSX_RELEASE:= $(shell test ! -d '/etc/mach_init.d' > /dev/null 2>&1 ; echo $$?)

ifeq (${DEB_CONF},1)
  DISTRIBUTION= ubuntu
  include $(srcdir)/apt.mk
  include $(srcdir)/ubuntu.am
  include $(srcdir)/accounts.am
else ifeq (${SUSE_RELEASE},1)
  DISTRIBUTION= suse
  include zypper.am
  include $(srcdir)/accounts.am
else ifeq (${FEDORA_RELEASE},1)
  RHEL_RELEASE= 0
  DISTRIBUTION= fedora
  include $(srcdir)/yum.mk
  include $(srcdir)/fedora.am
  include $(srcdir)/accounts.am
else ifeq (${CENTOS_RELEASE},1)
  DISTRIBUTION= centos
  include $(srcdir)/yum.mk
  include $(srcdir)/centos.mk
  include $(srcdir)/accounts.am
else ifeq (${RHEL_RELEASE},1)
  DISTRIBUTION= rhel
  include $(srcdir)/yum.mk
  include $(srcdir)/centos.mk
  include $(srcdir)/accounts.am
else ifeq (${FREEBSD_RELEASE},1)
  DISTRIBUTION= freebsd9
  include $(srcdir)/freebsd.am
else ifeq (${OSX_RELEASE},1)
  DISTRIBUTION= osx
  include $(srcdir)/osx.am
else
  DISTRIBUTION= unknown
endif

