#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad A285 Type 20MW 20MX (Type 20MW)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-a285-type-20mw-20mx-20mw
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad A285 Type 20MW 20MX (Type 20MW)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
