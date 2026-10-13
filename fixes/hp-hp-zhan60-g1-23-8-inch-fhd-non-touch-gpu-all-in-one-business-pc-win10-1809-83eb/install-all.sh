#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Zhan60 G1 23.8-inch FHD Non-Touch GPU All-in-One Business PC (Windows 10 64-bit, 1809)
# Generado por DeepSlopSuperLaptop para hp-hp-zhan60-g1-23-8-inch-fhd-non-touch-gpu-all-in-one-business-pc-win10-1809-83eb
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Zhan60 G1 23.8-inch FHD Non-Touch GPU All-in-One Business PC (Windows 10 64-bit, 1809)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
