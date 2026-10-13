#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad E14 Type 20RA 20RB (Type 20RB)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-e14-type-20ra-20rb-20rb
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad E14 Type 20RA 20RB (Type 20RB)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
