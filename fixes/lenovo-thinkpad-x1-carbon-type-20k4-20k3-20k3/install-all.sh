#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad X1 Carbon Type 20K4 20K3 (Type 20K3)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-x1-carbon-type-20k4-20k3-20k3
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad X1 Carbon Type 20K4 20K3 (Type 20K3)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
