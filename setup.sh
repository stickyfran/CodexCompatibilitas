#!/bin/bash
# ==============================================================================
# CodexCompatibilitas — Asistente Maestro Interactivo de Hardware OEM para Linux
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verificar que python3 esté disponible
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 no está instalado en el sistema."
    exit 1
fi

exec python3 "$DIR/scripts/auto_hardware_setup.py" "$@"
