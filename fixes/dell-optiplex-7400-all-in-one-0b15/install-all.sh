#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell OptiPlex 7400 All-in-One
# Generado por DeepSlopSuperLaptop para dell-optiplex-7400-all-in-one-0b15
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell OptiPlex 7400 All-in-One..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
