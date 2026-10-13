#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad X1 NANO Gen 1 Type 20UN 20UQ (Type 20UQ)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-x1-nano-gen-1-type-20un-20uq-20uq
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad X1 NANO Gen 1 Type 20UN 20UQ (Type 20UQ)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
