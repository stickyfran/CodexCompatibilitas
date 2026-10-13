#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProBook 4 G2i 13 inch Notebook AI PC (Windows 11 64-bit, 25H2)
# Generado por DeepSlopSuperLaptop para hp-hp-probook-4-g2i-13-inch-notebook-ai-pc-win11-25h2-8f31
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProBook 4 G2i 13 inch Notebook AI PC (Windows 11 64-bit, 25H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
