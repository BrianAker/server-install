# vim:ft=make

PIP_DIR:= .ansible
PIP_BIN_DIR:= $(srcdir)/$(PIP_DIR)/bin
PIP:= $(PIP_BIN_DIR)/pip
ACTIVATE:= $(PIP_BIN_DIR)/activate

VIRTUALENV= virtualenv

$(PIP_DIR)/$(dirstamp):
	$(info $(VIRTUALENV) $(PIP_DIR))
	$(VIRTUALENV) $(PIP_DIR)
	@$(TOUCH) $@
	$(info virtualenv installed, run the following command to add ansible to your path:)
	$(info . $(ACTIVATE))

$(PIP): $(PIP_DIR)/$(dirstamp)

define pip_install_r
$(shell . $(PIP_BIN_DIR)/activate && $(PIP_BIN_DIR)/pip install --quiet -r $1)
endef

define pip_upgrade_r
$(shell . $(PIP_BIN_DIR)/activate && $(PIP) install --upgrade pip && $(PIP_BIN_DIR)/pip install --upgrade --quiet -r $1)
endef

.PHONY: upgrade-pip
upgrade-pip:
	@$(PIP) install --upgrade pip
	@$(PIP) freeze | awk -F'==' '{ print $1 }' | xargs $(PIP) install --upgrade

MAINTAINERCLEAN+= $(PIP_DIR)
