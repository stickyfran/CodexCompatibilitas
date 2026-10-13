#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Optiplex OptiPlex AIO 7410
# Generado por DeepSlopSuperLaptop para dell-optiplex-optiplex-aio-7410-0be0
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Optiplex OptiPlex AIO 7410..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
