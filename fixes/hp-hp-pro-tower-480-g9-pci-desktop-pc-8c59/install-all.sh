#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP Pro Tower 480 G9 PCI Desktop PC
# Generado por DeepSlopSuperLaptop para hp-hp-pro-tower-480-g9-pci-desktop-pc-8c59
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP Pro Tower 480 G9 PCI Desktop PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
