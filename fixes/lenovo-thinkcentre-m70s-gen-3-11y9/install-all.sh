#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkCentre M70S Gen 3 (Type 11Y9)
# Generado por DeepSlopSuperLaptop para lenovo-thinkcentre-m70s-gen-3-11y9
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkCentre M70S Gen 3 (Type 11Y9)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
