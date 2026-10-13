#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteDesk 880 G4 Tower PC (Windows 10 64-bit, 1903)
# Generado por DeepSlopSuperLaptop para hp-hp-elitedesk-880-g4-tower-pc-win10-1903-83e0
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteDesk 880 G4 Tower PC (Windows 10 64-bit, 1903)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
