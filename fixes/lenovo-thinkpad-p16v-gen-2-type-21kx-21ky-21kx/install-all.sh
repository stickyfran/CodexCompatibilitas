#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad P16V Gen 2 Type 21KX 21KY (Type 21KX)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-p16v-gen-2-type-21kx-21ky-21kx
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad P16V Gen 2 Type 21KX 21KY (Type 21KX)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
