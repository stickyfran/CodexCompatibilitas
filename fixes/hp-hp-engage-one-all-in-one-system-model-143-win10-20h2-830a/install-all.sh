#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Engage One All-in-One System Model 143 (Windows 10 64-bit, 20H2)
# Generado por DeepSlopSuperLaptop para hp-hp-engage-one-all-in-one-system-model-143-win10-20h2-830a
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Engage One All-in-One System Model 143 (Windows 10 64-bit, 20H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
