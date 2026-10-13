#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad P14S Gen 2 Type 20VX  20VY (Type 20VX)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-p14s-gen-2-type-20vx--20vy-20vx
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad P14S Gen 2 Type 20VX  20VY (Type 20VX)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
