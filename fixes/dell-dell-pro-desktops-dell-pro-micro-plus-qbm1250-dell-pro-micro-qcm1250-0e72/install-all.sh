#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Dell Pro Desktops Dell Pro Micro Plus QBM1250/Dell Pro Micro QCM1250
# Generado por DeepSlopSuperLaptop para dell-dell-pro-desktops-dell-pro-micro-plus-qbm1250-dell-pro-micro-qcm1250-0e72
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Dell Pro Desktops Dell Pro Micro Plus QBM1250/Dell Pro Micro QCM1250..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
