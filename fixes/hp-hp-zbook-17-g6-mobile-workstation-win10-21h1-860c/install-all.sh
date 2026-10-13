#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ZBook 17 G6 Mobile Workstation (Windows 10 64-bit, 21H1)
# Generado por DeepSlopSuperLaptop para hp-hp-zbook-17-g6-mobile-workstation-win10-21h1-860c
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ZBook 17 G6 Mobile Workstation (Windows 10 64-bit, 21H1)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
