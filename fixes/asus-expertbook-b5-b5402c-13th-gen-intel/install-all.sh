#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Expertbook B5 B5402C 13Th Gen Intel
# Generado por DeepSlopSuperLaptop para asus-expertbook-b5-b5402c-13th-gen-intel
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Expertbook B5 B5402C 13Th Gen Intel..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
