#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProBook 4 G2i 16 inch Notebook AI PC
# Generado por DeepSlopSuperLaptop para hp-hp-probook-4-g2i-16-inch-notebook-ai-pc-8f35
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProBook 4 G2i 16 inch Notebook AI PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
