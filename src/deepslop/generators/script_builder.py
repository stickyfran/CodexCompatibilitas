import os
from typing import Dict, Any
from deepslop.models import LaptopModel


class ScriptBuilder:
    """Genera el script integral 'install-all.sh' para cualquier laptop soportada."""

    @staticmethod
    def generate_installer_script(model: LaptopModel, output_dir: str) -> str:
        os.makedirs(output_dir, exist_ok=True)
        script_path = os.path.join(output_dir, "install-all.sh")

        lines = [
            "#!/bin/bash",
            "# ==========================================================================",
            f"# Script de Instalación Automatizado — {model.vendor} {model.model_name}",
            f"# Generado por DeepSlopSuperLaptop para {model.id}",
            "# Sin daemons que gasten batería. 100% nativo.",
            "# ==========================================================================",
            "set -e",
            "",
            'echo "🚀 Aplicando configuraciones de hardware para ' + f'{model.vendor} {model.model_name}..."',
            "",
        ]

        # 1. Configuración de Audio
        if "audio" in model.components or "audio_amp" in model.components:
            lines.extend([
                "# --- 1. Audio (PipeWire / Firmware) ---",
                'echo "🔊 Configurando audio de alta fidelidad..."',
            ])
            # Si tiene Cirrus amp
            if "audio_amp" in model.components:
                lines.extend([
                    "if [ -d /lib/firmware/cirrus ]; then",
                    "    sudo cp -f ./audio/*.bin ./audio/*.wmfw /lib/firmware/cirrus/ 2>/dev/null || true",
                    '    echo "  ✓ Firmware Cirrus Logic copiado a /lib/firmware/cirrus/"',
                    "fi",
                ])
            # Si tiene PipeWire EQ
            lines.extend([
                "mkdir -p ~/.config/pipewire/pipewire.conf.d/",
                "if [ -f ./audio/99-speakers.conf ]; then",
                "    cp -f ./audio/99-speakers.conf ~/.config/pipewire/pipewire.conf.d/",
                '    echo "  ✓ Perfil de ecualización PipeWire instalado"',
                "    systemctl --user restart pipewire pipewire-pulse 2>/dev/null || true",
                "fi",
                "",
            ])

        # 2. Perfil de Color (ICC / ICM)
        if "display" in model.components or "display_color" in model.components:
            lines.extend([
                "# --- 2. Perfil de Color Oficial ---",
                'echo "🎨 Importando calibración de color del panel..."',
                "mkdir -p ~/.local/share/icc/",
                "if ls ./display/*.icm 1> /dev/null 2>&1; then",
                "    cp -f ./display/*.icm ~/.local/share/icc/",
                "    for p in ./display/*.icm; do",
                '        colormgr import-profile "$p" 2>/dev/null || true',
                "    done",
                '    echo "  ✓ Perfiles de color registrados en colord"',
                "fi",
                "",
            ])

        # 3. Teclado / Hotkeys
        if "keyboard_rgb" in model.components:
            lines.extend([
                "# --- 3. Teclado y Controladores ---",
                'echo "⌨️ Configurando teclado e iluminación..."',
                "if [ -f ./kmod/install.sh ]; then",
                "    sudo ./kmod/install.sh",
                "fi",
                "",
            ])

        # 4. Modos Térmicos y Ventiladores
        lines.extend([
            "# --- 4. Modo Térmico por Defecto ---",
            "if [ -f /sys/firmware/acpi/platform_profile ]; then",
            '    echo "balanced" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null 2>&1 || true',
            '    echo "  ✓ Perfil térmico establecido en \'balanced\'"',
            "fi",
            "",
            'echo "🎉 ¡Configuración completada exitosamente!"',
            'echo "Reinicie la sesión o el equipo para disfrutar de la experiencia completa."',
        ])

        with open(script_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

        os.chmod(script_path, 0o755)
        return script_path
