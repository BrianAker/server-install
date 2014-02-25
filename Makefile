# vim:ft=automake
#

.SUFFIXES:

PKG_INSTALLER=
PKG_UPDATE=
PKG_UPGRADE=
PKG_SEARCH_INSTALL= $(PKG_INSTALLER) $(1)
BASE_INSTALL_PATH= /usr/

srcdir= $(shell pwd)/
HOSTNAME:= `hostname`
HOST_TYPE:= `hostname | cut -d'-' -f1`
HOST_UUID:= `hostname | cut -d'-' -f2`
ALL_MAKEFILES:= $(wildcard *.am) 
ALL_SCRIPTS:= $(wildcard *.sh) 
ALL_PLAYBOOKS:= $(wildcard *.yml) 
ANSIBLE_CHECK= ansible-playbook --syntax-check
CURL=curl --silent --show-error

JENKINS_SLAVES=

USER_EXISTS:= $(shell id $(CREATE_USER) > /dev/null 2>&1 ; echo $$?)

DIST_MAKEFILES:=

.PHONY: all show check install base_install deploy upgrade clean

all: public_keys files/pkg-pubkey.cert roles/common/files/RPM-GPG-KEY-EPEL-6

clean:
	rm -f public_keys/brian public_keys/jenkins

check: bootstrap.yml maintenance.yml site.yml
	$(foreach f,$^,$(ANSIBLE_CHECK) $(f);)

public_keys: public_keys/brian public_keys/deploy public_keys/jenkins

public_keys/brian:
	@ssh-import-id -o public_keys/brian brianaker

public_keys/jenkins:
	@ssh-import-id -o public_keys/jenkins d-ci

files/pkg-pubkey.cert:
	@$(CURL) -o $@ http://trac.pcbsd.org/export/780f3da562b72643c04b47a59d277102a09abbca/src-sh/pc-extractoverlay/desktop-overlay/usr/local/etc/pkg-pubkey.cert

install: all
	ansible-playbook site.yml

install-ansible-user:
	ansible-playbook site.yml --limit=localhost -s -i hosts

upgrade:
	ansible-playbook maintenance.yml

localhost:
	ansible-playbook site.yml --limit=localhost

install-ansible:
	$(MAKE) install-virtualenv
	virtualenv ~/.python
	cp templates/pythonrc ~/.pythonrc
	. ~/.pythonrc
	pip install ansible

show:
	@echo "HOSTNAME ${HOSTNAME}"
	@echo "HOST_TYPE ${HOST_TYPE}"
	@echo "HOST_UUID ${HOST_UUID}"
	@echo "DISTRIBUTION: ${DISTRIBUTION}"

roles/common/files/RPM-GPG-KEY-EPEL-6:
	@$(CURL) -o $@ https://fedoraproject.org/static/A4D647E9.txt

deploy: install

.DEFAULT_GOAL:= all

.NOTPARALLEL:
