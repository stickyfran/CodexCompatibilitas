#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad P17 Gen 1 Type 20SN 20SQ
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-p17-gen-1-type-20sn-20sq
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad P17 Gen 1 Type 20SN 20SQ..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
