# vim:ft=make

PIP_DIR:= .ansible
PIP_BIN_DIR= $(srcdir)/$(PIP_DIR)/bin
PIP= $(PIP_BIN_DIR)/pip

PATH:=$(PIP_BIN_DIR):$(PATH)

$(PIP_DIR)/$(dirstamp):
	virtualenv $(PIP_DIR)
	@$(TOUCH) $@

$(PIP): $(PIP_DIR)/$(dirstamp)

define pip_install_r
$(shell . $(PIP_BIN_DIR)/activate && $(PIP_BIN_DIR)/pip install -r $1)
endef

define pip_upgrade_r
$(shell . $(PIP_BIN_DIR)/activate && $(PIP_BIN_DIR)/pip install --upgrade -r $1)
endef

MAINTAINERCLEAN+= $(PIP_DIR)
