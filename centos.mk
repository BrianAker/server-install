# vim:ft=automake
#

BASE_INSTALL_PATH= /usr/

include $(srcdir)bundle.am
include $(srcdir)projects.am

PIP= pip
PIP_INSTALL= $(PIP) install --quiet

VPATH= /usr/bin

stamp-h1:
	@touch stamp-h1

.PHONY: pkg_update
pkg_update:
	$(PKG_UPDATE)
	$(PKG_UPGRADE)
	$(MAKE) stamp-h1

prep-local:

# Keep yum updated
EXTRA_HOOK+= yum-cron
.PHONY: yum-cron
yum-cron:
	-$(PKG_INSTALLER) yum-plugin-fastestmirror yum-cron PackageKit-yum PackageKit-yum-plugin
	@if test -x /bin/chkconfig; then \
	  chkconfig yum-cron on ; \
	  service yum-cron start; \
	  elif test -x /usr/sbin/chkconfig; then \
	  /usr/sbin/chkconfig yum-cron on ; \
	  service yum-cron restart ; \
	  elif test -x /sbin/chkconfig; then \
	  /sbin/chkconfig yum-cron on ; \
	  service yum-cron restart ; \
	  fi

python-sphinx: /usr/bin/sphinx-build
/usr/bin/sphinx-build:
	$(PIP_INSTALL) sphinx

BASE_DEV_HOOK+= /usr/bin/cpanm
/usr/bin/cpanm:
	-$(PKG_INSTALLER) perl-CPAN
	curl -L http://cpanmin.us | perl - --sudo App::cpanminus
	ln -s /usr/local/bin/cpanm /usr/bin/cpanm

BASE_DEV_HOOK+= local-virtualenv 
local-virtualenv:
	$(PIP_INSTALL) virtualenv

install-virtualenv: easy_install
	easy_install virtualenv

BASE_DEV_LOCAL+= $(PROTOBUF)
PROTOBUF:= protobuf protobuf-compiler protobuf-devel

BASE_DEV_HOOK+= local-java
local-java:
	-$(PKG_INSTALLER) java-1.7.0-openjdk-devel java-1.7.0-openjdk
	-$(PKG_INSTALLER) dejavu-fonts-common dejavu-sans-fonts

LIBRARIES:= libevent libcurl libuuid boost zlib pcre pam libgcrypt readline openssl cyrus-sasl

BASE_DEV_HOOK+= libraries
libraries: | $(LIBRARIES)
$(LIBRARIES):
	-$(PKG_INSTALLER) $@ $@-devel

BASE_DEV_HOOK+= rpmbuild
/usr/bin/rpmbuild:
	-$(PKG_INSTALLER) rpm-build

.PHONY: post
post:

EXTRA_HOOK+= security
.PHONY: security
security: yum-cron

easy_install: pkg-config
	$(PKG_INSTALLER) python-setuptools

$(PIP): easy_install
	easy_install pip

ssh-import-id:
	$(PIP_INSTALL)  ssh-import-id

include $(srcdir)local.am
