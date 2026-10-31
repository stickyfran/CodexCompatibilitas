#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Ejecutando con sudo..."
    exec sudo "$0" "$@"
fi

echo "[1/2] Verificando tabla térmica GDDV de ASUS en BIOS (INTC1042:00)..."
if [ -f /sys/devices/platform/INTC1042:00/data_vault ]; then
    GDDV_STR="$(strings /sys/devices/platform/INTC1042:00/data_vault | grep -E 'Std_30W|ASUS' | head -n 3 | tr '\n' ' ')"
    echo "  -> Tabla GDDV detectada en BIOS: ${GDDV_STR}"
else
    echo "  -> Advertencia: No se encontró /sys/devices/platform/INTC1042:00/data_vault"
fi

echo "[2/2] Habilitando e iniciando demonios térmicos y de perfiles de energía..."
systemctl enable --now thermald.service
systemctl enable --now power-profiles-daemon.service

echo ""
echo "==================================================================="
echo " ¡Configuración Térmica Intel DPTF (GDDV) + ASUS WMI activa!"
echo " - thermald.service        : $(systemctl is-active thermald.service)"
echo " - power-profiles-daemon   : $(systemctl is-active power-profiles-daemon.service)"
echo " - Perfil actual           : $(powerprofilesctl get 2>/dev/null || echo 'balanced')"
echo "==================================================================="
