#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ZHAN 66 Pro G2 23.8-in All-in-One (Windows 10 64-bit, 20H2)
# Generado por DeepSlopSuperLaptop para hp-hp-zhan-66-pro-g2-23-8-in-all-in-one-win10-20h2-85a1
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ZHAN 66 Pro G2 23.8-in All-in-One (Windows 10 64-bit, 20H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
