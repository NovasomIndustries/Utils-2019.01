#!/bin/sh
. /etc/sysconfig/wireless
ifconfig eth0 down
killall udhcpc
wpa_supplicant -Dnl80211 -i${WLAN_DEVICE} -c/etc/wpa_supplicant.conf -B
udhcpc -i ${WLAN_DEVICE} &

#Use the code below for a static ip wifi address
#if [ "${WLAN_USE_DHCP}" == "Y" ]; then
#	udhcpc -i ${WLAN_DEVICE} &
#else
#	ifconfig ${WLAN_DEVICE} ${WLAN_IP_ADDRESS} up
#	route add default gw ${WLAN_GATEWAY}
#fi

