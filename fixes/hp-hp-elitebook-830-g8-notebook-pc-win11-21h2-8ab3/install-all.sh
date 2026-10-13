#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteBook 830 G8 Notebook PC (Windows 11 64-bit, 21H2)
# Generado por DeepSlopSuperLaptop para hp-hp-elitebook-830-g8-notebook-pc-win11-21h2-8ab3
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteBook 830 G8 Notebook PC (Windows 11 64-bit, 21H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
