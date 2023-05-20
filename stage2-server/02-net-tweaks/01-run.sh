#!/bin/bash -e

install -v -d						"${ROOTFS_DIR}/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant-wlan0.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/"
install -v -m 644 files/wlan0.network			"${ROOTFS_DIR}/etc/systemd/network/"
install -v -m 644 files/eth0.network			"${ROOTFS_DIR}/etc/systemd/network/"

if [ -v WPA_COUNTRY ]; then
	on_chroot <<- EOF
		SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_wifi_country "${WPA_COUNTRY}"
	EOF
fi

if [ -v WPA_ESSID ] && [ -v WPA_PASSWORD ]; then
on_chroot <<EOF
set -o pipefail
wpa_passphrase "${WPA_ESSID}" "${WPA_PASSWORD}" | tee -a "/etc/wpa_supplicant/wpa_supplicant-wlan0.conf"
EOF
elif [ -v WPA_ESSID ]; then
cat >> "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant-wlan0.conf" << EOL

network={
	ssid="${WPA_ESSID}"
	key_mgmt=NONE
}
EOL
fi

# Disable wifi on 5GHz models if WPA_COUNTRY is not set
mkdir -p "${ROOTFS_DIR}/var/lib/systemd/rfkill/"
if [ -n "$WPA_COUNTRY" ]; then
    echo 0 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-3f300000.mmcnr:wlan"
    echo 0 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-fe300000.mmcnr:wlan"
else
    echo 1 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-3f300000.mmcnr:wlan"
    echo 1 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-fe300000.mmcnr:wlan"
fi

on_chroot << EOF
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable wpa_supplicant@wlan0
EOF
