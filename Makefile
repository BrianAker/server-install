# vim:ft=make

.SUFFIXES:

BUILD:=
CHECK:=
DISTCLEAN:=
MAINTAINERCLEAN:=
PREREQ:=

PKG_INSTALLER=
PKG_UPDATE=
PKG_UPGRADE=
PKG_SEARCH_INSTALL= $(PKG_INSTALLER) $(1)
BASE_INSTALL_PATH= /usr/

ROLE_FILES=
ROLE_FILES+= $(ROLE_VARS)
ROLE_FILES+= $(ROLE_DEFAULTS)
ROLE_FILES+= $(ROLE_TASKS)
ROLE_FILES+= $(ROLE_HANDLERS)

HOSTNAME:= `hostname`
HOST_TYPE:= `hostname | cut -d'-' -f1`
HOST_UUID:= `hostname | cut -d'-' -f2`
ALL_SCRIPTS:= $(wildcard *.sh) 

include aux/common.mk
include aux/pip.mk
include aux/ansible.mk
include aux/git.mk

TASK_DIRS:= tasks defaults handlers meta
SUB_ROLES:= base validate_input_parameters

RAW_ROLES=
RAW_ROLES+= $(foreach dir,$(TASK_DIRS),$(subst /$(dir),,$(shell find roles -type d -name '$(dir)')))
RAW_ROLES+= $(foreach dir,$(SUB_ROLES),$(shell find roles -type d -name '$(dir)'))
ROLES:= $(sort $(RAW_ROLES))

ROLE_VARS:= $(addsuffix /vars/main.yml, $(ROLES))
ROLE_DEFAULTS:= $(addsuffix /defaults/main.yml, $(ROLES))
ROLE_TASKS:= $(addsuffix /tasks/main.yml, $(ROLES))
ROLE_HANDLERS:= $(addsuffix /handlers/main.yml, $(ROLES))
ROLE_META:= $(addsuffix /meta/main.yml, $(ROLES))

ROLEBOOKS+= $(addsuffix /role.yml, $(ROLES))
PLAYBOOKS+= $(wildcard *.yml) 

JENKINS_SLAVES=

USER_EXISTS:= $(shell id $(CREATE_USER) > /dev/null 2>&1 ; echo $$?)

$(ROLE_META): support/meta.yml
	@if test -f $@; then \
	  $(TOUCH) $< $@; \
	  git add --intent-to-add $@; \
	else \
	  $(MKDIR_P) $(@D); \
	  $(INSTALL) $< $@; \
	  git add --intent-to-add $@; \
	fi

$(ROLE_FILES): support/main.yml
	@if test -f $@; then \
	  $(TOUCH) $< $@; \
	  git add --intent-to-add $@; \
	else \
	  $(MKDIR_P) $(@D); \
	  $(INSTALL) $< $@; \
	  git add --intent-to-add $@; \
	fi

$(ROLEBOOKS): support/role.yml $(ROLE_FILES) $(ROLE_META)
	@cp $< $@
	@echo "  roles: [ '$(subst roles/,,$(@D))' ]" >> $@

BUILD+= $(ROLEBOOKS)

DIST_MAKEFILES:=

.PHONY: all
all: $(ROLE_FILES) $(ROLE_META) $(BUILD) public_keys files/pkg-pubkey.cert roles/common/files/RPM-GPG-KEY-EPEL-6

.PHONY: clean
clean:
	@rm -rf $(BUILD)
	@rm -f public_keys/brian public_keys/jenkins
	@find roles | grep role.yml | xargs rm

.PHONY: distclean
distclean: clean distclean-am

.PHONY: distclean-am
distclean-am:
	@rm -rf $(PREREQ)
	@rm -rf $(DISTCLEAN)

.PHONY: maintainer-clean
maintainer-clean: distclean
	@rm -rf $(MAINTAINERCLEAN)

.PHONY: print_check
print_check:
	@echo "$(CHECK)"
	@echo "$(ROLEBOOKS)"

.PHONY: check
check: all $(CHECK)

public_keys: public_keys/brian public_keys/deploy public_keys/jenkins

public_keys/brian:
	@$(SSH_IMPORT_ID) -o public_keys/brian brianaker

public_keys/jenkins:
	@$(SSH_IMPORT_ID) -o public_keys/jenkins d-ci

files/pkg-pubkey.cert:
	@$(CURL) -o $@ http://trac.pcbsd.org/export/780f3da562b72643c04b47a59d277102a09abbca/src-sh/pc-extractoverlay/desktop-overlay/usr/local/etc/pkg-pubkey.cert

.PHONY: install
install: all
	$(ANSIBLE_PLAYBOOK) site.yml -u deploy

.PHONY: install-ansible-user
install-ansible-user:
	$(ANSIBLE_PLAYBOOK) site.yml --limit=localhost -s -i hosts

.PHONY: upgrade
upgrade: all
	$(ANSIBLE_PLAYBOOK) maintenance.yml

.PHONY: localhost
localhost: all
	$(ANSIBLE_PLAYBOOK) site.yml --limit=localhost

roles/common/files/RPM-GPG-KEY-EPEL-6:
	@$(CURL) -o $@ https://fedoraproject.org/static/A4D647E9.txt

.PHONY: deploy
deploy: install

.DEFAULT_GOAL:= all

.NOTPARALLEL:
