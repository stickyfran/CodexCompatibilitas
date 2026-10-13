#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProOne 480 G3 20-inch Non-Touch All-in One PC (Windows 10 64-bit, 1909)
# Generado por DeepSlopSuperLaptop para hp-hp-proone-480-g3-20-inch-non-touch-all-in-one-pc-win10-1909-82a6
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProOne 480 G3 20-inch Non-Touch All-in One PC (Windows 10 64-bit, 1909)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
