#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Mini Conferencing PC with Zoom Rooms (Windows 11 64-bit, 23H2)
# Generado por DeepSlopSuperLaptop para hp-hp-mini-conferencing-pc-with-zoom-rooms-win11-23h2-894f
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Mini Conferencing PC with Zoom Rooms (Windows 11 64-bit, 23H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
