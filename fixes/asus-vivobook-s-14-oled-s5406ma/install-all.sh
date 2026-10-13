#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Vivobook S 14 Oled S5406Ma
# Generado por DeepSlopSuperLaptop para asus-vivobook-s-14-oled-s5406ma
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Vivobook S 14 Oled S5406Ma..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
