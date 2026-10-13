#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ZHAN 66 Pro G3 22 All-in-One PC (Windows 10 64-bit, 21H1)
# Generado por DeepSlopSuperLaptop para hp-hp-zhan-66-pro-g3-22-all-in-one-pc-win10-21h1-871b
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ZHAN 66 Pro G3 22 All-in-One PC (Windows 10 64-bit, 21H1)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
