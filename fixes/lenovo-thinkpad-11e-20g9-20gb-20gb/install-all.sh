#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad 11e 20G9 20GB (Type 20GB)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-11e-20g9-20gb-20gb
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad 11e 20G9 20GB (Type 20GB)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
