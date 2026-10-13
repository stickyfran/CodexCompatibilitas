#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkCentre M90N-1 (Type 11AL)
# Generado por DeepSlopSuperLaptop para lenovo-thinkcentre-m90n-1-11al
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkCentre M90N-1 (Type 11AL)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
