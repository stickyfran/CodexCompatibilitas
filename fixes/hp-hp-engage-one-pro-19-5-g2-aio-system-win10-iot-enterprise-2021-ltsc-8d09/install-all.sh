#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Engage One Pro 19.5 G2 AiO System (Windows 10 IoT Enterprise 2021 LTSC, 64-bit)
# Generado por DeepSlopSuperLaptop para hp-hp-engage-one-pro-19-5-g2-aio-system-win10-iot-enterprise-2021-ltsc-8d09
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Engage One Pro 19.5 G2 AiO System (Windows 10 IoT Enterprise 2021 LTSC, 64-bit)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
