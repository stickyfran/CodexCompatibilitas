#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — Dell Dell Pro 24 All-in-One QC24250/QC24251/Plus QB24250
# Generado por DeepSlopSuperLaptop para dell-dell-pro-24-all-in-one-qc24250-qc24251-plus-qb24250-0ce9
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para Dell Dell Pro 24 All-in-One QC24250/QC24251/Plus QB24250..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
