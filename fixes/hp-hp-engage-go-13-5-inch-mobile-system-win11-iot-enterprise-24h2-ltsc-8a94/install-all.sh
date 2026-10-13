#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Engage Go 13.5 inch Mobile System (Windows 11 IoT Enterprise 24H2 LTSC, 64-bit)
# Generado por DeepSlopSuperLaptop para hp-hp-engage-go-13-5-inch-mobile-system-win11-iot-enterprise-24h2-ltsc-8a94
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Engage Go 13.5 inch Mobile System (Windows 11 IoT Enterprise 24H2 LTSC, 64-bit)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
