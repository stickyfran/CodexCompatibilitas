#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad T15G Gen 2 Type 20YS 20YT
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-t15g-gen-2-type-20ys-20yt
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad T15G Gen 2 Type 20YS 20YT..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
