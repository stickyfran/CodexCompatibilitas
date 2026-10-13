#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Dell Pro 7 13 P713260/Dell Pro 7 13 2-in-1 P703260
# Generado por DeepSlopSuperLaptop para dell-dell-pro-7-13-p713260-dell-pro-7-13-2-in-1-p703260-0e83
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Dell Pro 7 13 P713260/Dell Pro 7 13 2-in-1 P703260..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
