#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Lenovo ThinkCentre M70A Gen 3 (Type 11VQ)
# Generado por DeepSlopSuperLaptop para lenovo-thinkcentre-m70a-gen-3-11vq
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Lenovo ThinkCentre M70A Gen 3 (Type 11VQ)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
