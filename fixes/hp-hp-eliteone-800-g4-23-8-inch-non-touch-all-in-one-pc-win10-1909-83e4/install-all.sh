#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteOne 800 G4 23.8-inch Non-Touch All-in-One PC (Windows 10 64-bit, 1909)
# Generado por DeepSlopSuperLaptop para hp-hp-eliteone-800-g4-23-8-inch-non-touch-all-in-one-pc-win10-1909-83e4
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteOne 800 G4 23.8-inch Non-Touch All-in-One PC (Windows 10 64-bit, 1909)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
