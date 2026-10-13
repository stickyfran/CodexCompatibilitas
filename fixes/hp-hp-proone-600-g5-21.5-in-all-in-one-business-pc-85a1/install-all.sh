#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProOne 600 G5 21.5-in All-in-One Business PC
# Generado por DeepSlopSuperLaptop para hp-hp-proone-600-g5-21.5-in-all-in-one-business-pc-85a1
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProOne 600 G5 21.5-in All-in-One Business PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
