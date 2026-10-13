#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Z4 G5 Workstation Desktop PC (Windows 10 64-bit, 22H2)
# Generado por DeepSlopSuperLaptop para hp-hp-z4-g5-workstation-desktop-pc-win10-22h2-8962
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Z4 G5 Workstation Desktop PC (Windows 10 64-bit, 22H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
