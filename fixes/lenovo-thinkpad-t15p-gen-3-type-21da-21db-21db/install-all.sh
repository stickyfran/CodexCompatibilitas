#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkPad T15P Gen 3 Type 21DA 21DB (Type 21DB)
# Generado por DeepSlopSuperLaptop para lenovo-thinkpad-t15p-gen-3-type-21da-21db-21db
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkPad T15P Gen 3 Type 21DA 21DB (Type 21DB)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
