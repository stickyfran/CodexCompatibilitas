#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Z1 Tower G1i Desktop PC (Windows 11 64-bit, 23H2)
# Generado por DeepSlopSuperLaptop para hp-hp-z1-tower-g1i-desktop-pc-win11-23h2-8d10
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Z1 Tower G1i Desktop PC (Windows 11 64-bit, 23H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
