#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Ejecutando con sudo..."
    exec sudo "$0" "$@"
fi

KVER="$(uname -r)"
echo "Desinstalando driver nativo hid-asus-lamparray..."

for devpath in /sys/bus/hid/devices/0018:0B05:19B6.*; do
    if [ -e "$devpath" ]; then
        devname="$(basename "$devpath")"
        if [ -e "/sys/bus/hid/drivers/asus_lamparray/${devname}" ]; then
            echo "$devname" > /sys/bus/hid/drivers/asus_lamparray/unbind || true
        fi
        if [ ! -e "/sys/bus/hid/drivers/asus/${devname}" ]; then
            echo "$devname" > /sys/bus/hid/drivers/asus/bind || true
        fi
    fi
done

if lsmod | grep -q hid_asus_lamparray; then
    rmmod hid_asus_lamparray || true
fi

rm -f "/usr/lib/modules/${KVER}/updates/hid-asus-lamparray.ko"
rm -f /etc/modprobe.d/asus-lamparray.conf
rm -f /etc/modules-load.d/asus-lamparray.conf
rm -f /etc/udev/rules.d/99-asus-lamparray.rules
rm -f /etc/pacman.d/hooks/99-asus-lamparray.hook
depmod -a "$KVER"
systemctl disable asus-fnlock-state.service 2>/dev/null || true
rm -f /etc/systemd/system/asus-fnlock-state.service
rm -rf /var/lib/asus-kbd
systemctl daemon-reload 2>/dev/null || true
udevadm control --reload-rules

echo "Driver hid-asus-lamparray desinstalado."
