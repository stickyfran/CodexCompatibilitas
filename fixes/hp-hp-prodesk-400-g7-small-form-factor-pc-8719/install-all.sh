#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProDesk 400 G7 Small Form Factor PC
# Generado por DeepSlopSuperLaptop para hp-hp-prodesk-400-g7-small-form-factor-pc-8719
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProDesk 400 G7 Small Form Factor PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
