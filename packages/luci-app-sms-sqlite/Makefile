include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI interface for SMS SQLite Sync
LUCI_DEPENDS:=+sqlite3-cli +sms-sqlite-sync
LUCI_PKGARCH:=all
PKG_LICENSE:=GPL-2.0

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-sms-sqlite/install
	$(call Package/luci-app-sms-sqlite/install/default,$(1))
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./files/sms_sqlite $(1)/usr/libexec/rpcd/sms_sqlite
endef

# call BuildPackage