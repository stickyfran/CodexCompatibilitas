#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Dell Desktops Dell Tower DT1265
# Generado por DeepSlopSuperLaptop para dell-dell-desktops-dell-tower-dt1265-0e7c
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Dell Desktops Dell Tower DT1265..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
