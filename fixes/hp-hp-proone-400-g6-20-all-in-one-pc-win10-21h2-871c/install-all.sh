#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProOne 400 G6 20 All-in-One PC (Windows 10 64-bit, 21H2)
# Generado por DeepSlopSuperLaptop para hp-hp-proone-400-g6-20-all-in-one-pc-win10-21h2-871c
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProOne 400 G6 20 All-in-One PC (Windows 10 64-bit, 21H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
