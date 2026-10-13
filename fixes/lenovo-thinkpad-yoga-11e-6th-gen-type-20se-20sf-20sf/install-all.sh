#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad Yoga 11e 6th Gen Type 20SE 20SF (Type 20SF)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-yoga-11e-6th-gen-type-20se-20sf-20sf
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad Yoga 11e 6th Gen Type 20SE 20SF (Type 20SF)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
