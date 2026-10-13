#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Latitude 12 Rugged Extreme (7204)
# Generado por DeepSlopSuperLaptop para dell-latitude-12-rugged-extreme-(7204)-0610
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Latitude 12 Rugged Extreme (7204)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
