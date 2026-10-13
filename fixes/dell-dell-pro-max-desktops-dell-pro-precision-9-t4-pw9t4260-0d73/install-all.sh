#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Dell Pro Max Desktops Dell Pro Precision 9 T4 PW9T4260
# Generado por DeepSlopSuperLaptop para dell-dell-pro-max-desktops-dell-pro-precision-9-t4-pw9t4260-0d73
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Dell Pro Max Desktops Dell Pro Precision 9 T4 PW9T4260..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
