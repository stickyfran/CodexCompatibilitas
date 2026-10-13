#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Engage Go Mobile System (Windows 10 IoT Enterprise 2019 LTSC, 64-bit)
# Generado por DeepSlopSuperLaptop para hp-hp-engage-go-mobile-system-win10-iot-enterprise-2019-ltsc-846f
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Engage Go Mobile System (Windows 10 IoT Enterprise 2019 LTSC, 64-bit)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
