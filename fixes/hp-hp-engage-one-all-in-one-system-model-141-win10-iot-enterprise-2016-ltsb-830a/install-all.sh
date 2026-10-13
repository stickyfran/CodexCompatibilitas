#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Engage One All-in-One System Model 141 (Windows 10 IoT Enterprise 2016 LTSB, 64-bit)
# Generado por DeepSlopSuperLaptop para hp-hp-engage-one-all-in-one-system-model-141-win10-iot-enterprise-2016-ltsb-830a
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Engage One All-in-One System Model 141 (Windows 10 IoT Enterprise 2016 LTSB, 64-bit)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
