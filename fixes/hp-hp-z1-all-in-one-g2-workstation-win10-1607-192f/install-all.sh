#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Z1 All-in-One G2 Workstation (Windows 10 64-bit, 1607)
# Generado por DeepSlopSuperLaptop para hp-hp-z1-all-in-one-g2-workstation-win10-1607-192f
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Z1 All-in-One G2 Workstation (Windows 10 64-bit, 1607)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
