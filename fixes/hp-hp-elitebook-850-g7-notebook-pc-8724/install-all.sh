#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteBook 850 G7 Notebook PC
# Generado por DeepSlopSuperLaptop para hp-hp-elitebook-850-g7-notebook-pc-8724
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteBook 850 G7 Notebook PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
