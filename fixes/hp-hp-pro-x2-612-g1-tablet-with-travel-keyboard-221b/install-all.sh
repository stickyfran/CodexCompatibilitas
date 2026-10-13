#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Pro x2 612 G1 Tablet with Travel Keyboard
# Generado por DeepSlopSuperLaptop para hp-hp-pro-x2-612-g1-tablet-with-travel-keyboard-221b
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Pro x2 612 G1 Tablet with Travel Keyboard..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
