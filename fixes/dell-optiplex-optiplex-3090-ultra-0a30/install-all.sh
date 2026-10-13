#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Optiplex OptiPlex 3090 Ultra
# Generado por DeepSlopSuperLaptop para dell-optiplex-optiplex-3090-ultra-0a30
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Optiplex OptiPlex 3090 Ultra..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
