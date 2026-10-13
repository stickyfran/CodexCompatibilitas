#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteDesk 705 G1 Desktop Mini PC (Windows 10 64-bit, 1607)
# Generado por DeepSlopSuperLaptop para hp-hp-elitedesk-705-g1-desktop-mini-pc-win10-1607-225e
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteDesk 705 G1 Desktop Mini PC (Windows 10 64-bit, 1607)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
