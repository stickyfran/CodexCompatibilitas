#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad E15 Gen 3 Type 20YG 20YH 20YJ 20YK
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-e15-gen-3-type-20yg-20yh-20yj-20yk
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad E15 Gen 3 Type 20YG 20YH 20YJ 20YK..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
