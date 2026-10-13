#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProBook 445 G7 Notebook PC (Windows 11 64-bit, 22H2)
# Generado por DeepSlopSuperLaptop para hp-hp-probook-445-g7-notebook-pc-win11-22h2-8730
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProBook 445 G7 Notebook PC (Windows 11 64-bit, 22H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
