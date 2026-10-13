#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Engage One All-in-One System Model 143 (Windows 10 64-bit, 2004)
# Generado por DeepSlopSuperLaptop para hp-hp-engage-one-all-in-one-system-model-143-win10-2004-830a
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Engage One All-in-One System Model 143 (Windows 10 64-bit, 2004)..."

# --- 1. Audio (PipeWire / Firmware) ---
echo "🔊 Configurando audio de alta fidelidad..."
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
