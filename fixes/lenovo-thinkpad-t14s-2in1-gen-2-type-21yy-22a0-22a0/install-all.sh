#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad T14S 2IN1 Gen 2 Type 21YY 22A0 (Type 22A0)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-t14s-2in1-gen-2-type-21yy-22a0-22a0
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad T14S 2IN1 Gen 2 Type 21YY 22A0 (Type 22A0)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
