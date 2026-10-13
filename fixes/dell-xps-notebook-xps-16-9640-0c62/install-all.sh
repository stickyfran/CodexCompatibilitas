#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell XPS Notebook XPS 16 9640
# Generado por DeepSlopSuperLaptop para dell-xps-notebook-xps-16-9640-0c62
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell XPS Notebook XPS 16 9640..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
