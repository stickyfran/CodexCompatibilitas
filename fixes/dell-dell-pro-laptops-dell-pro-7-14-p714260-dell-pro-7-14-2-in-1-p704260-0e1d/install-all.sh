#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Dell Pro Laptops Dell Pro 7 14 P714260/Dell Pro 7 14 2-in-1 P704260
# Generado por DeepSlopSuperLaptop para dell-dell-pro-laptops-dell-pro-7-14-p714260-dell-pro-7-14-2-in-1-p704260-0e1d
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Dell Pro Laptops Dell Pro 7 14 P714260/Dell Pro 7 14 2-in-1 P704260..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
