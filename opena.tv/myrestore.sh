#!/bin/sh
#Script myrestore.sh (-rwxr-xr-x) liegt in /usr/script/
#
# Unused languages
opkg --force-depends remove enigma2-locale-{ar,bg,ca,cs,da,el,en-gb,es,et,fa,fi,fr,fy,he,hk,hr,hu,is,it,ku,lt,lv,nb,nl,no,pl,pt,pt-br,ro,ru,sk,sl,sr,sv,th,tr,uk,zh}
opkg --force-depends remove enigma2-locale-{meta,meta-dbg,meta-dev}
# WLAN
opkg --force-depends remove oe-alliance-wifi enigma2-plugin-drivers-network-usb-{ath9k-htc,carl9170,r8712u,rt2500,rt2800,rt73,rtl8187,rtl8192cu,zd1211rw} enigma2-plugin-systemplugins-wirelesslan rtl8192cu kernel-module-{8192cu,ath9k-htc,ath9k-common,ath9k-hw,carl9170,ath,r8712u,rt2500usb,rt2800usb,rt2800lib,rt73usb,rt2x00usb,rt2x00lib,rtl8187,zd1211rw} packagegroup-base-wifi wpa-supplicant-passphrase wpa-supplicant-cli wpa-supplicant wireless-tools
# Sonstiges
opkg --force-depends remove enigma2-plugin-systemplugins-{positionersetup,satfinder,hdmicec,commoninterfaceassignment} enigma2-plugin-extensions-{cutlisteditor,programmlistenupdater}
# opkg update # unknown ???
# Useful tools
opkg install htop nano mc hdparm # smartmontools # unknown ???
# Change png
cp /hdd/vu+bilder/rc.png /usr/share/enigma2/rc_models/vu3/rc.png
cp /hdd/vu+bilder/remote.html /usr/share/enigma2/rc_models/vu3/remote.html
cp /hdd/vu+bilder/rcpositions.xml /usr/share/enigma2/rc_models/rcpositions.xml
cp /hdd/vu+bilder/vuduo2.png usr/share/enigma2/vuduo2.png
echo "done"
