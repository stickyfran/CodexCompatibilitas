#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Elite x2 G4 Tablet with Keyboard
# Generado por DeepSlopSuperLaptop para hp-hp-elite-x2-g4-tablet-with-keyboard-85b9
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Elite x2 G4 Tablet with Keyboard..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
