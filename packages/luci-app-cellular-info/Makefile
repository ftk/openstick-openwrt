include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Cellular Information
LUCI_DEPENDS:=+qmi-utils +modem-at-engine +jsonfilter
LUCI_PKGARCH:=all
PKG_LICENSE:=GPL-3.0

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-cellular-info/install
	$(call Package/luci-app-cellular-info/install/default,$(1))
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./files/cellular_info $(1)/usr/libexec/rpcd/cellular_info
endef

# call BuildPackage