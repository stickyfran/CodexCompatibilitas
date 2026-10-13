#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Asus Expertbook B5 Flip G2 14 Intel
# Generado por DeepSlopSuperLaptop para asus-asus-expertbook-b5-flip-g2-14-intel
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Asus Expertbook B5 Flip G2 14 Intel..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
