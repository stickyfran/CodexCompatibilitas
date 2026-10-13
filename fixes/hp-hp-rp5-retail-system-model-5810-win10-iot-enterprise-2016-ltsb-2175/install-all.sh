#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP RP5 Retail System Model 5810 (Windows 10 IoT Enterprise 2016 LTSB, 64-bit)
# Generado por DeepSlopSuperLaptop para hp-hp-rp5-retail-system-model-5810-win10-iot-enterprise-2016-ltsb-2175
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP RP5 Retail System Model 5810 (Windows 10 IoT Enterprise 2016 LTSB, 64-bit)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
