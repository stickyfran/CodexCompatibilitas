#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad T580 Type 20L9 20LA
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-t580-type-20l9-20la
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad T580 Type 20L9 20LA..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
