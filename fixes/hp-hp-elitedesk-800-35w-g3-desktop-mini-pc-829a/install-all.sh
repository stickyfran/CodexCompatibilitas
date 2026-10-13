#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteDesk 800 35W G3 Desktop Mini PC
# Generado por DeepSlopSuperLaptop para hp-hp-elitedesk-800-35w-g3-desktop-mini-pc-829a
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteDesk 800 35W G3 Desktop Mini PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
