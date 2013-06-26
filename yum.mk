# vim:ft=automake
#
YUM:= yum -y --quiet
PKG_CACHE:= $(YUM) makecache
PKG_INSTALLER:= $(YUM) install
PKG_PROVIDES:= $(YUM) whatprovides
PKG_UPGRADE:= $(YUM) upgrade
PKG_SEARCH_INSTALL= $(PKG_INSTALLER) $(1) || ($(PKG_PROVIDES) $(1) | head -1 | cut -d : -f 1 | xargs $(PKG_INSTALLER))
