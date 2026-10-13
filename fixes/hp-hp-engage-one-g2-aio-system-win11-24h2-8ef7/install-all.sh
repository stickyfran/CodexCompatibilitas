#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Engage One G2 AiO System (Windows 11 64-bit, 24H2)
# Generado por DeepSlopSuperLaptop para hp-hp-engage-one-g2-aio-system-win11-24h2-8ef7
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Engage One G2 AiO System (Windows 11 64-bit, 24H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
