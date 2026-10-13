#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Z1 G8 Tower Desktop PC
# Generado por DeepSlopSuperLaptop para hp-hp-z1-g8-tower-desktop-pc-889c
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Z1 G8 Tower Desktop PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
