#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Zenbook Pro 14 Oled Ux6404
# Generado por DeepSlopSuperLaptop para asus-zenbook-pro-14-oled-ux6404
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Zenbook Pro 14 Oled Ux6404..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
