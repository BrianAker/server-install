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

JENKINS_SLAVES=

USER_EXISTS := $(shell id $(CREATE_USER) > /dev/null 2>&1 ; echo $$?)

DIST_MAKEFILES := ubuntu.am fedora.am centos.mk freebsd.am osx.am

include $(srcdir)dist.mk
include $(srcdir)misc.mk

.PHONY: all show check install base_install deploy

all:

check:
	$(foreach each_makefile,$(DIST_MAKEFILES),$(MAKE) --warn-undefined-variables --dry-run $(each_makefile);)
	$(foreach each_file,$(ALL_SCRIPTS),bash -e -n $(each_file);)

install-jenkins-slave: install
	@echo "JENKINS SLAVE"
	$(MAKE) base_jenkins_slave
	$(MAKE) tangentci
	$(MAKE) lazlo
	$(MAKE) secure-host
	@cat /etc/ssh/sshd_config
	reboot

install: 
	$(MAKE) install-am

base_jenkins_slave: | java

install-ansible-user:
	ansible-playbook site.yml --limit=localhost -s -i hosts

localhost:
	ansible-playbook -i hosts site.yml --limit=localhost

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

deploy:
ifndef INSTALL_SERVER
	@echo "INSTALL_SERVER was not set"
endif
ifdef INSTALL_SERVER
	scp bootstrap.sh "$$INSTALL_SERVER":~/
	-git remote rm "$$INSTALL_SERVER"
	git remote add "$$INSTALL_SERVER" ssh://"$$INSTALL_SERVER"/~/server-install.git
	ssh -o "RequestTTY yes" -o "BatchMode yes" -o "StrictHostKeyChecking no" -t "$$INSTALL_SERVER" ./bootstrap.sh
endif


.DEFAULT_GOAL:= all

.NOTPARALLEL:
