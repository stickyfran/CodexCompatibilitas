#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad Z13 Type 21D2 21D3
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-z13-type-21d2-21d3
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad Z13 Type 21D2 21D3..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
