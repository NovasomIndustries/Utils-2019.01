################################################################################
#
# rtl8723bs
#
################################################################################

RTL8723BS_BT_VERSION = HEAD
RTL8723BS_BT_SITE = $(call github,Novasomindustries,rtl8723bs_bt,HEAD)
RTL8723BS_BT_LICENSE = LGPL-2.1+

define RTL8723BS_BT_BUILD_CMDS
        $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define RTL8723BS_BT_INSTALL_TARGET_CMDS
        $(INSTALL) -m 0755 -D $(@D)/rtk_hciattach $(TARGET_DIR)/usr/bin/rtk_hciattach
	$(INSTALL) -m 0755 -D $(@D)/go_bt.sh $(TARGET_DIR)/bin/go_bt.sh
endef

$(eval $(generic-package))
