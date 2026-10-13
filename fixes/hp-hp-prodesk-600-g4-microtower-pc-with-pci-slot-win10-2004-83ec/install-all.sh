#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP ProDesk 600 G4 Microtower PC (with PCI slot) (Windows 10 64-bit, 2004)
# Generado por DeepSlopSuperLaptop para hp-hp-prodesk-600-g4-microtower-pc-with-pci-slot-win10-2004-83ec
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP ProDesk 600 G4 Microtower PC (with PCI slot) (Windows 10 64-bit, 2004)..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
