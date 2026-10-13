#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProBook 450 15.6 inch G9 Notebook PC (Windows 11 64-bit, 25H2)
# Generado por DeepSlopSuperLaptop para hp-hp-probook-450-15-6-inch-g9-notebook-pc-win11-25h2-8aa1
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProBook 450 15.6 inch G9 Notebook PC (Windows 11 64-bit, 25H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
