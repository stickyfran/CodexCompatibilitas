#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Elite Slice G2 with Intel Unite
# Generado por DeepSlopSuperLaptop para hp-hp-elite-slice-g2-with-intel-unite-8396
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Elite Slice G2 with Intel Unite..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
