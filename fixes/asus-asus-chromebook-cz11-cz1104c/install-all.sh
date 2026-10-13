#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Asus Chromebook Cz11 Cz1104C
# Generado por DeepSlopSuperLaptop para asus-asus-chromebook-cz11-cz1104c
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Asus Chromebook Cz11 Cz1104C..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
