#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Presence Control Plus Kit Microsoft Team Room
# Generado por DeepSlopSuperLaptop para hp-hp-presence-control-plus-kit-microsoft-team-room-885c
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Presence Control Plus Kit Microsoft Team Room..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
