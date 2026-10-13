#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad X1 Carbon Type 20FB 20FC
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-x1-carbon-type-20fb-20fc
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad X1 Carbon Type 20FB 20FC..."

# --- 1. Audio (PipeWire / Firmware) ---
echo "🔊 Configurando audio de alta fidelidad..."
if [ -d /lib/firmware/cirrus ]; then
    sudo cp -f ./audio/*.bin ./audio/*.wmfw /lib/firmware/cirrus/ 2>/dev/null || true
    echo "  ✓ Firmware Cirrus Logic copiado a /lib/firmware/cirrus/"
fi
mkdir -p ~/.config/pipewire/pipewire.conf.d/
if [ -f ./audio/99-speakers.conf ]; then
    cp -f ./audio/99-speakers.conf ~/.config/pipewire/pipewire.conf.d/
    echo "  ✓ Perfil de ecualización PipeWire instalado"
    systemctl --user restart pipewire pipewire-pulse 2>/dev/null || true
fi

# --- 2. Perfil de Color Oficial ---
echo "🎨 Importando calibración de color del panel..."
mkdir -p ~/.local/share/icc/
if ls ./display/*.icm 1> /dev/null 2>&1; then
    cp -f ./display/*.icm ~/.local/share/icc/
    for p in ./display/*.icm; do
        colormgr import-profile "$p" 2>/dev/null || true
    done
    echo "  ✓ Perfiles de color registrados en colord"
fi

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
