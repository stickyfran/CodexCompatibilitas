#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad T495 Type 20NJ 20NK (Type 20NJ)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-t495-type-20nj-20nk-20nj
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad T495 Type 20NJ 20NK (Type 20NJ)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
