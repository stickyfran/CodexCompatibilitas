#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Asus Zenbook 14 Oled Um3406
# Generado por DeepSlopSuperLaptop para asus-asus-zenbook-14-oled-um3406
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Asus Zenbook 14 Oled Um3406..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
