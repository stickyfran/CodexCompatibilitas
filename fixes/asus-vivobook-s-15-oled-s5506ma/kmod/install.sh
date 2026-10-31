#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Ejecutando con sudo..."
    exec sudo "$0" "$@"
fi

KVER="$(uname -r)"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERM_DIR="/home/kes/Documentos/Programando/AsusS5506MAConfiguracion/01-kernel-rgb-driver"
MOD_DEST="/usr/lib/modules/${KVER}/updates"

# Verificar dependencias críticas para compilar en kernels CachyOS Clang/LTO
if ! command -v ld.lld &>/dev/null; then
    echo "[!] Dependencia crítica faltante: 'lld' (requerido para compilar módulos en kernels Clang/ThinLTO de CachyOS)."
    echo "    Instalando 'lld' automáticamente vía pacman..."
    pacman -S --needed --noconfirm lld
fi

echo "[1/5] Compilando módulo nativo hid-asus-lamparray.ko para kernel ${KVER}..."
make -C "$SRC_DIR" KVER="$KVER"
chown -R kes:kes "$SRC_DIR" 2>/dev/null || true

echo "[2/5] Instalando módulo en ${MOD_DEST}..."
mkdir -p "$MOD_DEST"
cp -f "${SRC_DIR}/hid-asus-lamparray.ko" "${MOD_DEST}/"
depmod -a "$KVER"

echo "[3/5] Configurando color por defecto (Perfil Primero: R=213, G=108, B=39, Brillo=255) y carga automática..."
cat << 'EOF' > /etc/modprobe.d/asus-lamparray.conf
# Color inicial en el arranque (Perfil "Primero": #D56C27, Brillo 100%)
options hid_asus_lamparray default_red=213 default_green=108 default_blue=39 default_brightness=255 turn_off_on_suspend=1
EOF

cat << 'EOF' > /etc/modules-load.d/asus-lamparray.conf
led-class-multicolor
hid-asus-lamparray
EOF

echo "[4/5] Instalando regla udev para enlazar 0018:0B05:19B6 al driver nativo asus_lamparray..."
cat << 'EOF' > /etc/udev/rules.d/99-asus-lamparray.rules
# Enlazar teclado ITE5570 (0018:0B05:19B6) al driver nativo del kernel asus_lamparray
SUBSYSTEM=="hid", KERNEL=="0018:0B05:19B6.*", DRIVER=="asus", RUN+="/bin/sh -c 'modprobe hid-asus-lamparray; echo %k > /sys/bus/hid/drivers/asus/unbind 2>/dev/null || true; echo %k > /sys/bus/hid/drivers/asus_lamparray/bind 2>/dev/null || true'"
SUBSYSTEM=="leds", KERNEL=="asus::kbd_backlight_rgb", RUN+="/bin/chmod 0666 /sys/class/leds/%k/brightness /sys/class/leds/%k/multi_intensity /sys/class/leds/%k/rainbow_mode /sys/class/leds/%k/fn_lock"
EOF

# Hook de Pacman para recompilar automáticamente cuando actualices el kernel en CachyOS
mkdir -p /etc/pacman.d/hooks
cat << EOF > /etc/pacman.d/hooks/99-asus-lamparray.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Path
Target = usr/lib/modules/*/vmlinuz

[Action]
Description = Recompilando driver nativo ASUS LampArray RGB para el nuevo kernel...
When = PostTransaction
Exec = /bin/sh -c 'for d in /usr/lib/modules/*/build; do kver=\$(basename \$(dirname "\$d")); make -C "${PERM_DIR}" KVER="\$kver" && mkdir -p "/usr/lib/modules/\$kver/updates" && cp -f "${PERM_DIR}/hid-asus-lamparray.ko" "/usr/lib/modules/\$kver/updates/" && depmod -a "\$kver"; done'
NeedsTargets
EOF

udevadm control --reload-rules

# Configurar persistencia dinámica de Fn-Lock (sin daemons, 100% oneshot)
mkdir -p /var/lib/asus-kbd
if [ ! -f /var/lib/asus-kbd/fnlock_state ]; then
    echo "1" > /var/lib/asus-kbd/fnlock_state
fi

# Limpiar parámetros erróneos en /etc/modprobe.d/asus.conf si existen
if [ -f /etc/modprobe.d/asus.conf ]; then
    sed -i '/fnlock_default/d' /etc/modprobe.d/asus.conf
    sed -i '/set_kbd_backlight/d' /etc/modprobe.d/asus.conf
fi

cat << 'EOF' > /etc/systemd/system/asus-fnlock-state.service
[Unit]
Description=Guardar y Restaurar Estado de Fn-Lock ASUS Vivobook
DefaultDependencies=no
After=local-fs.target systemd-modules-load.service
Before=shutdown.target reboot.target halt.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'if [ -f /var/lib/asus-kbd/fnlock_state ]; then val=$$(cat /var/lib/asus-kbd/fnlock_state 2>/dev/null); for i in $$(seq 1 30); do if [ -w /sys/class/leds/asus::kbd_backlight_rgb/fn_lock ]; then echo "$$val" > /sys/class/leds/asus::kbd_backlight_rgb/fn_lock 2>/dev/null; break; fi; sleep 0.1; done; fi'
ExecStop=/bin/sh -c 'mkdir -p /var/lib/asus-kbd && if [ -r /sys/class/leds/asus::kbd_backlight_rgb/fn_lock ]; then cat /sys/class/leds/asus::kbd_backlight_rgb/fn_lock > /var/lib/asus-kbd/fnlock_state; fi'

[Install]
WantedBy=basic.target
EOF

systemctl daemon-reload
systemctl enable --now asus-fnlock-state.service 2>/dev/null || true

echo "[5/5] Activando driver nativo del kernel en vivo..."
modprobe led-class-multicolor
if lsmod | grep -q hid_asus_lamparray; then
    rmmod hid_asus_lamparray
fi
modprobe hid-asus-lamparray

for devpath in /sys/bus/hid/devices/0018:0B05:19B6.*; do
    if [ -e "$devpath" ]; then
        devname="$(basename "$devpath")"
        if [ -e "/sys/bus/hid/drivers/asus/${devname}" ]; then
            echo "$devname" > /sys/bus/hid/drivers/asus/unbind || true
        fi
        if [ ! -e "/sys/bus/hid/drivers/asus_lamparray/${devname}" ]; then
            echo "$devname" > /sys/bus/hid/drivers/asus_lamparray/bind
        fi
    fi
done

chmod 0666 /sys/class/leds/asus::kbd_backlight_rgb/brightness \
           /sys/class/leds/asus::kbd_backlight_rgb/multi_intensity \
           /sys/class/leds/asus::kbd_backlight_rgb/rainbow_mode \
           /sys/class/leds/asus::kbd_backlight_rgb/fn_lock 2>/dev/null || true

rm -f /usr/lib/systemd/system-sleep/openrgb-resume.sh 2>/dev/null || true

echo ""
echo "==================================================================="
echo " ¡Driver Nativo del Kernel instalado y activo!"
echo " LED Multicolor sysfs: /sys/class/leds/asus::kbd_backlight_rgb"
echo " Color actual (R G B): $(cat /sys/class/leds/asus::kbd_backlight_rgb/multi_intensity 2>/dev/null)"
echo " Brillo actual       : $(cat /sys/class/leds/asus::kbd_backlight_rgb/brightness 2>/dev/null)/255"
echo "==================================================================="
