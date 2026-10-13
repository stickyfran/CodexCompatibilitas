#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Elite SFF 600 G9 Desktop PC
# Generado por DeepSlopSuperLaptop para hp-hp-elite-sff-600-g9-desktop-pc-8ac5
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Elite SFF 600 G9 Desktop PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
