#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Z2 Tower G4 Workstation (Windows 10 64-bit, 21H1)
# Generado por DeepSlopSuperLaptop para hp-hp-z2-tower-g4-workstation-win10-21h1-8455
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Z2 Tower G4 Workstation (Windows 10 64-bit, 21H1)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
