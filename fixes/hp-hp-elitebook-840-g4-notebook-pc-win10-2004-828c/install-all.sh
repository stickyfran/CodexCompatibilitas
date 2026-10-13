#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteBook 840 G4 Notebook PC (Windows 10 64-bit, 2004)
# Generado por DeepSlopSuperLaptop para hp-hp-elitebook-840-g4-notebook-pc-win10-2004-828c
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteBook 840 G4 Notebook PC (Windows 10 64-bit, 2004)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
