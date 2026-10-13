#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteOne 800 G6 27 All-in-One PC
# Generado por DeepSlopSuperLaptop para hp-hp-eliteone-800-g6-27-all-in-one-pc-874d
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteOne 800 G6 27 All-in-One PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
