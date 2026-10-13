#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ZHAN 66 Pro 15 G2 Notebook PC
# Generado por DeepSlopSuperLaptop para hp-hp-zhan-66-pro-15-g2-notebook-pc-85aa
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ZHAN 66 Pro 15 G2 Notebook PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
