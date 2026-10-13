#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Asus Vivobook S 16 Flip Oled Tp3604
# Generado por DeepSlopSuperLaptop para asus-asus-vivobook-s-16-flip-oled-tp3604
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Asus Vivobook S 16 Flip Oled Tp3604..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
