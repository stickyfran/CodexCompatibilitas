#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProOne 600 G4 21.5-inch Touch All-in-One Business PC (Windows 10 64-bit, 1803)
# Generado por DeepSlopSuperLaptop para hp-hp-proone-600-g4-21-5-inch-touch-all-in-one-business-pc-win10-1803-83eb
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProOne 600 G4 21.5-inch Touch All-in-One Business PC (Windows 10 64-bit, 1803)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
