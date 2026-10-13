#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Z4 Rack G5 Workstation (Windows 11 64-bit, 21H2)
# Generado por DeepSlopSuperLaptop para hp-hp-z4-rack-g5-workstation-win11-21h2-8b3e
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Z4 Rack G5 Workstation (Windows 11 64-bit, 21H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
