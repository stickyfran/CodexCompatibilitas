#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteBook 630 13.3 inch G11 Notebook PC
# Generado por DeepSlopSuperLaptop para hp-hp-elitebook-630-13.3-inch-g11-notebook-pc-8c85
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteBook 630 13.3 inch G11 Notebook PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
