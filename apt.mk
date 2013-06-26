# vim:ft=automake
#
PKG_INSTALLER:= apt-get install --yes
PKG_UPDATE:= apt-get update --yes 2>&1 > /dev/null
PKG_UPGRADE:= apt-get upgrade --yes 2>&1 > /dev/null
PKG_SEARCH_INSTALL= $(PKG_INSTALLER) $(1) || (apt-file search --package-only --fixed-string $(1) | sudo xargs $(PKG_INSTALLER))


