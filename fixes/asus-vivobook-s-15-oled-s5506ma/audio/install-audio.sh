#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PW_CONF_DIR="${HOME}/.config/pipewire/pipewire.conf.d"

echo "[1/2] Instalando perfil acústico OEM ASUS S5506MA (Dolby Atmos + Realtek SUBSYS_10433C10) en PipeWire..."
mkdir -p "$PW_CONF_DIR"
cp -f "${SCRIPT_DIR}/99-asus-s5506ma-audio.conf" "${PW_CONF_DIR}/99-asus-s5506ma-audio.conf"

echo "[2/2] Reiniciando servicios de audio de usuario (PipeWire / WirePlumber)..."
systemctl --user restart pipewire pipewire-pulse wireplumber
sleep 1

echo ""
echo "==================================================================="
echo " ¡Perfil de audio OEM ASUS S5506MA instalado y activo!"
echo " Filtros pasivos (0% CPU en reposo):"
echo "  - S5506MA Harman Kardon Speakers (Dolby OEM 20-Band + Bass Boost)"
echo "  - S5506MA AI Array Microphone (Realtek SUBSYS_10433C10 MIEQ)"
echo "==================================================================="
wpctl status | grep -A 10 "Audio" || true
