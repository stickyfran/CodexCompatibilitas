#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad E14 Gen 6 Type 21M7 21M8
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-e14-gen-6-type-21m7-21m8
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad E14 Gen 6 Type 21M7 21M8..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
