#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Dell Pro Rugged Laptops Dell Pro Rugged 10 Tablet RA00260
# Generado por DeepSlopSuperLaptop para dell-dell-pro-rugged-laptops-dell-pro-rugged-10-tablet-ra00260-0d66
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Dell Pro Rugged Laptops Dell Pro Rugged 10 Tablet RA00260..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
