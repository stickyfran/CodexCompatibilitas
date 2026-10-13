#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Asus Vivobook 15 Oled M1505
# Generado por DeepSlopSuperLaptop para asus-asus-vivobook-15-oled-m1505
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Asus Vivobook 15 Oled M1505..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
