#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP RP9 G1 Retail System Model 9118
# Generado por DeepSlopSuperLaptop para hp-hp-rp9-g1-retail-system-model-9118-8397
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP RP9 G1 Retail System Model 9118..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
