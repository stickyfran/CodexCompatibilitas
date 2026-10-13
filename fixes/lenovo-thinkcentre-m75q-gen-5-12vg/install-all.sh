#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkCentre M75Q Gen 5 (Type 12VG)
# Generado por DeepSlopSuperLaptop para lenovo-thinkcentre-m75q-gen-5-12vg
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkCentre M75Q Gen 5 (Type 12VG)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
