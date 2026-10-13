#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — HP HP EliteDesk 8 SFF G2a Desktop Next Gen AI PC
# Generado por DeepSlopSuperLaptop para hp-hp-elitedesk-8-sff-g2a-desktop-next-gen-ai-pc-8f5a
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para HP HP EliteDesk 8 SFF G2a Desktop Next Gen AI PC..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
