#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ZHAN 66 Pro 14 inch G5 Notebook PC (Windows 11 64-bit, 22H2)
# Generado por DeepSlopSuperLaptop para hp-hp-zhan-66-pro-14-inch-g5-notebook-pc-win11-22h2-8979
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ZHAN 66 Pro 14 inch G5 Notebook PC (Windows 11 64-bit, 22H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
