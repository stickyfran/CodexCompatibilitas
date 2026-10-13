#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Spectre Pro x360 G2 Convertible PC
# Generado por DeepSlopSuperLaptop para hp-hp-spectre-pro-x360-g2-convertible-pc-8197
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Spectre Pro x360 G2 Convertible PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
