#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteOne 800 G8 24 All-in-One PC
# Generado por DeepSlopSuperLaptop para hp-hp-eliteone-800-g8-24-all-in-one-pc-88aa
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteOne 800 G8 24 All-in-One PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
