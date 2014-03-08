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


#ROLES:= $(wildcard roles/*) 
RAW_ROLES:=
RAW_ROLES+= $(subst /tasks/main.yml,,$(wildcard roles/*/tasks/main.yml))
RAW_ROLES+= $(subst /meta/main.yml,,$(wildcard roles/*/meta/main.yml))
RAW_ROLES+= $(subst /tasks/main.yml,,$(wildcard roles/*/*/tasks/main.yml))
RAW_ROLES+= $(subst /meta/main.yml,,$(wildcard roles/*/*/meta/main.yml))
ROLES:= $(sort $(RAW_ROLES))

ROLE_VARS:= $(addsuffix /vars/main.yml, $(ROLES))
ROLE_DEFAULTS:= $(addsuffix /defaults/main.yml, $(ROLES))
ROLE_TASKS:= $(addsuffix /tasks/main.yml, $(ROLES))
ROLE_HANDLERS:= $(addsuffix /handlers/main.yml, $(ROLES))
ROLE_META:= $(addsuffix /meta/main.yml, $(ROLES))
ALL_ROLEBOOKS= $(addsuffix /role.yml, $(ROLES))
ANSIBLE_CHECK= ansible-playbook --syntax-check
CURL=curl --silent --show-error

ROLE_FILES=
ROLE_FILES+= $(ROLE_VARS)
ROLE_FILES+= $(ROLE_DEFAULTS)
ROLE_FILES+= $(ROLE_TASKS)
ROLE_FILES+= $(ROLE_HANDLERS)

JENKINS_SLAVES=

USER_EXISTS:= $(shell id $(CREATE_USER) > /dev/null 2>&1 ; echo $$?)

.PHONY: fill
fill: $(ROLE_FILES)

$(ROLE_META): support/meta.yml
	@if test -f $@; then \
	  touch -r $< $@; \
	  git add --intent-to-add $@; \
	else \
	  mkdir -p $(@D); \
	  cp $< $@; \
	  git add --intent-to-add $@; \
	fi

$(ROLE_FILES): support/main.yml
	@if test -f $@; then \
	  touch -r $< $@; \
	  git add --intent-to-add $@; \
	else \
	  mkdir -p $(@D); \
	  cp $< $@; \
	  git add --intent-to-add $@; \
	fi

$(ALL_ROLEBOOKS): support/role.yml
	@cp $< $@
	@echo "  roles: [ $(subst roles/,,$(@D)) ]" >> $@

.PHONY: print
print:
	@echo $(ROLES)

DIST_MAKEFILES:=

.PHONY: all
all: public_keys files/pkg-pubkey.cert roles/common/files/RPM-GPG-KEY-EPEL-6 $(ROLE_META) $(ROLE_FILES) $(ALL_ROLEBOOKS)

.PHONY: clean
clean:
	rm -f public_keys/brian public_keys/jenkins

.PHONY: check
check: all check-rolebooks check-playbook-am

.PHONY: check-playbook
check-playbook: check-playbook-am

.PHONY: check-playbook-am
check-playbook-am: $(ALL_PLAYBOOKS)
	$(foreach f,$^,$(ANSIBLE_CHECK) $(f);)

.PHONY: check-rolebooks
check-rolebooks: $(ALL_ROLEBOOKS) $(ROLE_FILES) $(ROLE_META) check-rolebooks-am

.PHONY: check-rolebooks-am
check-rolebooks-am: $(ALL_ROLEBOOKS)
	$(foreach f,$^,$(ANSIBLE_CHECK) $(f);)

public_keys: public_keys/brian public_keys/deploy public_keys/jenkins

public_keys/brian:
	@ssh-import-id -o public_keys/brian brianaker

public_keys/jenkins:
	@ssh-import-id -o public_keys/jenkins d-ci

files/pkg-pubkey.cert:
	@$(CURL) -o $@ http://trac.pcbsd.org/export/780f3da562b72643c04b47a59d277102a09abbca/src-sh/pc-extractoverlay/desktop-overlay/usr/local/etc/pkg-pubkey.cert

.PHONY: install
install: all
	ansible-playbook site.yml

.PHONY: install-ansible-user
install-ansible-user:
	ansible-playbook site.yml --limit=localhost -s -i hosts

.PHONY: upgrade
upgrade: all
	ansible-playbook maintenance.yml

.PHONY: localhost
localhost: all
	ansible-playbook site.yml --limit=localhost

.PHONY: install-ansible
install-ansible:
	$(MAKE) install-virtualenv
	virtualenv ~/.python
	cp templates/pythonrc ~/.pythonrc
	. ~/.pythonrc
	pip install ansible

.PHONY: show
show:
	@echo "HOSTNAME ${HOSTNAME}"
	@echo "HOST_TYPE ${HOST_TYPE}"
	@echo "HOST_UUID ${HOST_UUID}"
	@echo "DISTRIBUTION: ${DISTRIBUTION}"

roles/common/files/RPM-GPG-KEY-EPEL-6:
	@$(CURL) -o $@ https://fedoraproject.org/static/A4D647E9.txt

.PHONY: deploy
deploy: install

.DEFAULT_GOAL:= all

.NOTPARALLEL:
