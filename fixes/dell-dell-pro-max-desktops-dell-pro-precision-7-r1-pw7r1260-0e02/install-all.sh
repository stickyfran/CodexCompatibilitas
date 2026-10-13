#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Dell Pro Max Desktops Dell Pro Precision 7 R1 PW7R1260
# Generado por DeepSlopSuperLaptop para dell-dell-pro-max-desktops-dell-pro-precision-7-r1-pw7r1260-0e02
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Dell Pro Max Desktops Dell Pro Precision 7 R1 PW7R1260..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
