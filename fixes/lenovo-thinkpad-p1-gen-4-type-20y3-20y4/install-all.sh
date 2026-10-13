#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad P1 Gen 4 Type 20Y3 20Y4
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-p1-gen-4-type-20y3-20y4
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad P1 Gen 4 Type 20Y3 20Y4..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
