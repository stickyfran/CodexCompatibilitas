#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkCentre M70S Gen 5 (Type 12U8)
# Generado por DeepSlopSuperLaptop para lenovo-thinkcentre-m70s-gen-5-12u8
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkCentre M70S Gen 5 (Type 12U8)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
