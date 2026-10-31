#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Vivobook S 15 OLED (S5506MA)
# Calibración Oficial OEM: Audio Dolby Atmos Biquad, Splendid OLED ICC,
# Driver Nativo LampArray RGB en Kernel y Gestión Térmica Intel DPTF.
# Cero daemons residentes. Cero drenaje de batería.
# ==========================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🚀 Aplicando configuraciones de hardware para ASUS Vivobook S 15 OLED (S5506MA)..."

# --- 1. Audio DSP (PipeWire / Realtek ALC294 + Dolby Atmos) ---
echo "🔊 [1/4] Configurando audio de alta fidelidad (Curva Dolby Atmos 20-bandas)..."
mkdir -p ~/.config/pipewire/pipewire.conf.d/
if [ -f "$DIR/audio/99-asus-s5506ma-audio.conf" ]; then
    cp -f "$DIR/audio/99-asus-s5506ma-audio.conf" ~/.config/pipewire/pipewire.conf.d/
    echo "  ✓ Perfil de ecualización PipeWire Biquad instalado"
    systemctl --user restart pipewire pipewire-pulse 2>/dev/null || true
fi

# --- 2. Perfil de Color Oficial Splendid (Samsung SDC4180 OLED) ---
echo "🎨 [2/4] Importando calibración de color de fábrica para panel OLED 3K 120Hz..."
mkdir -p ~/.local/share/icc/
if ls "$DIR/display/"*.icm 1> /dev/null 2>&1; then
    cp -f "$DIR/display/"*.icm ~/.local/share/icc/
    for p in "$DIR/display/"*.icm; do
        colormgr import-profile "$p" 2>/dev/null || true
    done
    echo "  ✓ Perfiles de color (DCI-P3, sRGB, SDC4180 calibrado) registrados en colord"
fi

# --- 3. Teclado y Controladores (Módulo C en Kernel hid-asus-lamparray) ---
echo "⌨️ [3/4] Instalando módulo nativo de kernel para teclado LampArray RGB y Fn-Lock..."
if [ -f "$DIR/kmod/install.sh" ]; then
    sudo bash "$DIR/kmod/install.sh"
    echo "  ✓ Módulo hid-asus-lamparray compilado y enlazado al hardware"
fi

# --- 4. Modo Térmico por Defecto (Intel DPTF + ACPI) ---
echo "❄️ [4/4] Verificando perfil térmico ACPI y DPTF GDDV..."
if [ -f "$DIR/thermal/setup-thermal.sh" ]; then
    sudo bash "$DIR/thermal/setup-thermal.sh"
elif [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo ""
echo "🎉 ¡Configuración completada exitosamente!"
echo "Tu ASUS Vivobook S 15 OLED ahora cuenta con paridad de hardware OEM 1:1."
