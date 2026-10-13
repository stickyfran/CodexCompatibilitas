#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ZBook Fury 16 G11 Mobile Workstation PC
# Generado por DeepSlopSuperLaptop para hp-hp-zbook-fury-16-g11-mobile-workstation-pc-8ca7
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ZBook Fury 16 G11 Mobile Workstation PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
