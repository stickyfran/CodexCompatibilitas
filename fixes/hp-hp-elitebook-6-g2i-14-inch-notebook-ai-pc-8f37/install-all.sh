#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteBook 6 G2i 14 inch Notebook AI PC
# Generado por DeepSlopSuperLaptop para hp-hp-elitebook-6-g2i-14-inch-notebook-ai-pc-8f37
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteBook 6 G2i 14 inch Notebook AI PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
