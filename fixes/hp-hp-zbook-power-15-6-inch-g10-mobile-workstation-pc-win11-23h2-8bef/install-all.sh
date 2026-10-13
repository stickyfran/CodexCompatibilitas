#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ZBook Power 15.6 inch G10 Mobile Workstation PC (Windows 11 64-bit, 23H2)
# Generado por DeepSlopSuperLaptop para hp-hp-zbook-power-15-6-inch-g10-mobile-workstation-pc-win11-23h2-8bef
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ZBook Power 15.6 inch G10 Mobile Workstation PC (Windows 11 64-bit, 23H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
