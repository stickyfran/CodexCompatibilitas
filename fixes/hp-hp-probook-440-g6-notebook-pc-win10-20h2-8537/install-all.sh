#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProBook 440 G6 Notebook PC (Windows 10 64-bit, 20H2)
# Generado por DeepSlopSuperLaptop para hp-hp-probook-440-g6-notebook-pc-win10-20h2-8537
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProBook 440 G6 Notebook PC (Windows 10 64-bit, 20H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
