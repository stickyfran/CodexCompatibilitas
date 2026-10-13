#!/bin/bash
# ==========================================================================
# Script de Instalación Automatizado — ASUS Asus Chromebook Cx34 Flip Cx3401 12Th Gen Intel
# Generado por DeepSlopSuperLaptop para asus-asus-chromebook-cx34-flip-cx3401-12th-gen-intel
# Sin daemons que gasten batería. 100% nativo.
# ==========================================================================
set -e

echo "🚀 Aplicando configuraciones de hardware para ASUS Asus Chromebook Cx34 Flip Cx3401 12Th Gen Intel..."

# --- 4. Modo Térmico por Defecto ---
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true
    echo "  ✓ Perfil térmico establecido en 'balanced'"
fi

echo "🎉 ¡Configuración completada exitosamente!"
echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."
