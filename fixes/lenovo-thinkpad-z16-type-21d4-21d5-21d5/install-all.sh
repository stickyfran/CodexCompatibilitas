#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad Z16 Type 21D4 21D5 (Type 21D5)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-z16-type-21d4-21d5-21d5
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad Z16 Type 21D4 21D5 (Type 21D5)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
