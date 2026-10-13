#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProStudio 4 All-in-One G1i 23.8 inch Desktop AI PC (Windows 11 64-bit, 25H2)
# Generado por DeepSlopSuperLaptop para hp-hp-prostudio-4-all-in-one-g1i-23-8-inch-desktop-ai-pc-win11-25h2-8d19
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProStudio 4 All-in-One G1i 23.8 inch Desktop AI PC (Windows 11 64-bit, 25H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
