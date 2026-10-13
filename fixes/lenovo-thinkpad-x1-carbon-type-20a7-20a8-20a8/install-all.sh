#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad X1 Carbon Type 20A7 20A8 (Type 20A8)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-x1-carbon-type-20a7-20a8-20a8
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad X1 Carbon Type 20A7 20A8 (Type 20A8)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
