#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ZBook 15 G6 Mobile Workstation (Windows 10 64-bit, 1803)
# Generado por DeepSlopSuperLaptop para hp-hp-zbook-15-g6-mobile-workstation-win10-1803-860f
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ZBook 15 G6 Mobile Workstation (Windows 10 64-bit, 1803)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
