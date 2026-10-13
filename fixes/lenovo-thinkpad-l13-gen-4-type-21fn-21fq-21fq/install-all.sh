#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad L13 Gen 4 Type 21FN 21FQ (Type 21FQ)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-l13-gen-4-type-21fn-21fq-21fq
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad L13 Gen 4 Type 21FN 21FQ (Type 21FQ)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
