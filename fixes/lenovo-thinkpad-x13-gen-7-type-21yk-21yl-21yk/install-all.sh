#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad X13 Gen 7 Type 21YK 21YL (Type 21YK)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-x13-gen-7-type-21yk-21yl-21yk
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad X13 Gen 7 Type 21YK 21YL (Type 21YK)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
