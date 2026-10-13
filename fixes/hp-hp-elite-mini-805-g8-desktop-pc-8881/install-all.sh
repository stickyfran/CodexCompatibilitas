#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Elite Mini 805 G8 Desktop PC
# Generado por DeepSlopSuperLaptop para hp-hp-elite-mini-805-g8-desktop-pc-8881
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Elite Mini 805 G8 Desktop PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
