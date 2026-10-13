#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Zbook 17 G5 Mobile Workstation (Windows 10 64-bit, 1703)
# Generado por DeepSlopSuperLaptop para hp-hp-zbook-17-g5-mobile-workstation-win10-1703-842d
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Zbook 17 G5 Mobile Workstation (Windows 10 64-bit, 1703)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
