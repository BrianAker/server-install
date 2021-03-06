# vim:ft=make

ROLEBOOKS=
PLAYBOOKS=
GIST := https://gist.githubusercontent.com/BrianAker/e58417dac282131d2e2a/raw/84372d8b94e33a3dcea0144a2e9943e79922b325/ansible-requirements

ANSIBLE:= $(PIP_BIN_DIR)/ansible
ANSIBLE_PLAYBOOK:= $(PIP_BIN_DIR)/ansible-playbook
ANSIBLE_CHECK:= $(ANSIBLE_PLAYBOOK) --syntax-check
ANSIBLE_GALAXY:= $(PIP_BIN_DIR)/ansible-galaxy

ANSIBLE_PIP_REQUIREMENTS:= aux/ansible/pip.txt

$(ANSIBLE_PIP_REQUIREMENTS):
	$(MKDIR_P) $(@D)
	$(CURL) -o $@ $(GIST)

$(ANSIBLE_PLAYBOOK): $(ANSIBLE)

$(ANSIBLE_GALAXY): $(ANSIBLE)

$(ANSIBLE_CHECK): $(ANSIBLE)


PREREQ+= $(ANSIBLE)

$(ANSIBLE): $(PIP) $(ANSIBLE_PIP_REQUIREMENTS)
	$(if $(wildcard $(ANSIBLE)), $(call pip_install_r,$(ANSIBLE_PIP_REQUIREMENTS)), $(call pip_upgrade_r,$(ANSIBLE_PIP_REQUIREMENTS)))
	@$(TOUCH_R) $< $(ANSIBLE_PIP_REQUIREMENTS)

MAINTAINERCLEAN+= .ansible

CHECK+= check-playbook
CHECK+= check-rolebooks

.PHONY: check-playbook
check-playbook: $(PLAYBOOKS)
	$(foreach playbook,$(PLAYBOOKS),$(ANSIBLE_CHECK) $(playbook);)

.PHONY: check-rolebooks
check-rolebooks: $(ROLEBOOKS)
	$(foreach rolebook,$(ROLEBOOKS),$(ANSIBLE_CHECK) $(rolebook);)
