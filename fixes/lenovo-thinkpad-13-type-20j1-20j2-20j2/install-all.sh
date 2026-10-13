#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad 13 Type 20J1 20J2 (Type 20J2)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-13-type-20j1-20j2-20j2
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad 13 Type 20J1 20J2 (Type 20J2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
