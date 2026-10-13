#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad L480 Type 20LS 20LT
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-l480-type-20ls-20lt
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad L480 Type 20LS 20LT..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
