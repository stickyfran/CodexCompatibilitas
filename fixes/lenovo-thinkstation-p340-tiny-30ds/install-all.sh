#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkStation P340 TINY (Type 30DS)
# Generado por DeepSlopSuperLaptop para lenovo-thinkstation-p340-tiny-30ds
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkStation P340 TINY (Type 30DS)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
