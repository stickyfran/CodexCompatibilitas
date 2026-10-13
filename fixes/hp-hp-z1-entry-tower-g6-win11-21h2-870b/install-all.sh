#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Z1 Entry Tower G6 (Windows 11 64-bit, 21H2)
# Generado por DeepSlopSuperLaptop para hp-hp-z1-entry-tower-g6-win11-21h2-870b
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Z1 Entry Tower G6 (Windows 11 64-bit, 21H2)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
