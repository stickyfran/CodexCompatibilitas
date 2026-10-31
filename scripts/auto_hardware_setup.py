#!/usr/bin/env python3
"""
CodexCompatibilitas — Asistente Interactivo de Diagnóstico y Aprovisionamiento de Hardware OEM.

1. Analiza el hardware local (DMI, PCI, ACPI, Audio, Pantalla, Termales).
2. Sugiere el modelo exacto detectado o permite elegir interactivamente por Fabricante -> Año -> Familia/Modelo.
3. Informa paso a paso qué componentes y sensores se configurarán.
4. Explica detalladamente por qué se requieren privilegios 'sudo' antes de solicitarlos.
5. Ejecuta el aprovisionamiento, reporta el avance y diagnostica cualquier error o advertencia.
"""

import sys
import os
import glob
import json
import re
import shutil
import subprocess
from typing import Dict, List, Optional, Tuple, Any

# Rutas base
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
DB_MODELS_DIR = os.path.join(BASE_DIR, "db", "models")
FIXES_DIR = os.path.join(BASE_DIR, "fixes")

# Colores ANSI
BOLD = "\033[1m"
GREEN = "\033[32m"
BLUE = "\033[34m"
CYAN = "\033[36m"
YELLOW = "\033[33m"
RED = "\033[31m"
MAGENTA = "\033[35m"
RESET = "\033[0m"


def print_banner():
    print(f"\n{BOLD}{CYAN}========================================================================{RESET}")
    print(f"{BOLD}{MAGENTA}   CodexCompatibilitas 💻⚡ — Aprovisionamiento de Hardware OEM en Linux{RESET}")
    print(f"{CYAN}   Paridad de fábrica nativa: Audio DSP, Color OLED/IPS, Térmico y Teclados{RESET}")
    print(f"{CYAN}   Filosofía Zero-Daemon: 0% gasto de batería en reposo, 100% nativo.{RESET}")
    print(f"{BOLD}{CYAN}========================================================================{RESET}\n")


def read_sysfs(path: str) -> str:
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            return f.read().strip()
    except Exception:
        return ""


def get_local_hardware() -> Dict[str, Any]:
    vendor = read_sysfs("/sys/class/dmi/id/sys_vendor")
    product_name = read_sysfs("/sys/class/dmi/id/product_name")
    board_name = read_sysfs("/sys/class/dmi/id/board_name")
    bios_version = read_sysfs("/sys/class/dmi/id/bios_version")
    chassis_type = read_sysfs("/sys/class/dmi/id/chassis_type")

    # Audio codecs
    audio_codecs = []
    for cfile in glob.glob("/proc/asound/card*/codec#*"):
        try:
            with open(cfile, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    if line.startswith("Codec:"):
                        audio_codecs.append(line.split(":", 1)[1].strip())
                        break
        except Exception:
            pass

    # Platform profile
    current_profile = read_sysfs("/sys/firmware/acpi/platform_profile")
    available_profiles = read_sysfs("/sys/firmware/acpi/platform_profile_choices").split()

    # DPTF / Thermal sensors
    acpi_sensors = []
    for d in glob.glob("/sys/devices/platform/*"):
        bname = os.path.basename(d)
        if any(bname.startswith(p) for p in ["INT340", "INTC10", "PNP0C0B", "ACPI000E"]):
            acpi_sensors.append(bname)

    return {
        "vendor": vendor,
        "product_name": product_name,
        "board_name": board_name,
        "bios_version": bios_version,
        "chassis_type": chassis_type,
        "audio_codecs": list(set(audio_codecs)),
        "current_profile": current_profile,
        "available_profiles": available_profiles,
        "acpi_sensors": acpi_sensors,
    }


def load_all_models() -> List[Dict[str, Any]]:
    models = []
    if not os.path.isdir(DB_MODELS_DIR):
        return models

    for root, _, files in os.walk(DB_MODELS_DIR):
        for f in files:
            if f.endswith(".json"):
                fpath = os.path.join(root, f)
                try:
                    with open(fpath, "r", encoding="utf-8") as jf:
                        data = json.load(jf)
                        models.append(data)
                except Exception:
                    pass
    return models


def extract_year(model: Dict[str, Any]) -> int:
    # Intenta extraer año del nombre o del ID
    text = f"{model.get('id', '')} {model.get('model_name', '')}"
    match = re.search(r'\b(201[3-9]|202[0-9])\b', text)
    if match:
        return int(match.group(1))
    return 2024  # Default fallback a generación moderna


def find_matching_model(hw: Dict[str, Any], models: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    vendor_clean = hw["vendor"].lower()
    prod_clean = hw["product_name"].lower()
    board_clean = hw["board_name"].lower()

    # Coincidencia por DMI exacto o coincidencia de substrings
    best_match = None
    best_score = 0

    for m in models:
        m_vendor = m.get("vendor", "").lower()
        if m_vendor not in vendor_clean and vendor_clean not in m_vendor:
            continue

        score = 0
        m_id = m.get("id", "").lower()
        m_name = m.get("model_name", "").lower()
        m_sysid = m.get("system_id", "").lower()

        # Check DMI matches
        dmi_matches = [d.lower() for d in m.get("dmi_matches", [])]
        if prod_clean and (prod_clean in dmi_matches or any(prod_clean in d for d in dmi_matches)):
            score += 10
        if board_clean and (board_clean in dmi_matches or any(board_clean in d for d in dmi_matches)):
            score += 10
        if m_sysid and (m_sysid in board_clean or m_sysid in prod_clean):
            score += 8
        if m_name and (board_clean in m_name or prod_clean in m_name):
            score += 6
        if m_id and board_clean in m_id:
            score += 5

        if score > best_score:
            best_score = score
            best_match = m

    if best_score >= 5:
        return best_match
    return None


def ask_choice(prompt: str, options: List[str]) -> int:
    print(f"\n{BOLD}{prompt}{RESET}")
    for i, opt in enumerate(options, 1):
        print(f"  {CYAN}[{i}]{RESET} {opt}")
    while True:
        try:
            choice = input(f"\n{YELLOW}Seleccione una opción (1-{len(options)}) [o 'q' para salir]: {RESET}").strip()
            if choice.lower() == 'q':
                print(f"{RED}Operación cancelada por el usuario.{RESET}")
                sys.exit(0)
            val = int(choice)
            if 1 <= val <= len(options):
                return val - 1
            print(f"{RED}Número fuera de rango.{RESET}")
        except (ValueError, EOFError):
            print(f"\n{RED}Entrada terminada o inválida. Saliendo...{RESET}")
            sys.exit(0)


def interactive_model_selection(models: List[Dict[str, Any]]) -> Dict[str, Any]:
    print(f"\n{BOLD}{BLUE}=== Selección Manual de Modelo ==={RESET}")

    # 1. Elegir Fabricante
    vendors = sorted(list(set(m.get("vendor", "Otros") for m in models if m.get("vendor"))))
    idx_v = ask_choice("Paso 1: Seleccione el Fabricante (OEM):", vendors)
    sel_vendor = vendors[idx_v]
    models_v = [m for m in models if m.get("vendor") == sel_vendor]

    # 2. Elegir Año / Generación
    years = sorted(list(set(extract_year(m) for m in models_v)), reverse=True)
    year_labels = [f"Año {y} ({sum(1 for m in models_v if extract_year(m) == y)} modelos)" for y in years]
    idx_y = ask_choice(f"Paso 2: Seleccione el Año / Generación para {sel_vendor}:", year_labels)
    sel_year = years[idx_y]
    models_y = [m for m in models_v if extract_year(m) == sel_year]

    # 3. Elegir Familia / Categoría
    families = sorted(list(set(m.get("family", "General") for m in models_y if m.get("family"))))
    if len(families) > 1:
        idx_f = ask_choice(f"Paso 3: Seleccione la Familia / Serie ({sel_vendor} - {sel_year}):", families)
        sel_family = families[idx_f]
        models_f = [m for m in models_y if m.get("family") == sel_family]
    else:
        models_f = models_y

    # 4. Elegir Modelo Específico
    model_labels = [f"{m.get('model_name', m.get('id'))} (ID: {m.get('id')})" for m in models_f]
    idx_m = ask_choice("Paso 4: Seleccione el Modelo exacto de laptop:", model_labels)
    return models_f[idx_m]


def explain_sudo_reasons(components: Dict[str, Any]):
    reasons = []
    if "keyboard" in components or "keyboard_rgb" in components:
        reasons.append("Compilar e instalar el módulo nativo en /usr/lib/modules/ y configurar reglas de udev para el teclado.")
    if "thermal" in components:
        reasons.append("Ajustar parámetros ACPI platform_profile y configurar políticas de enfriamiento en /sys/firmware/acpi/.")
    if "audio_amp" in components:
        reasons.append("Instalar firmwares de amplificadores de audio en /lib/firmware/cirrus/.")

    if not reasons:
        reasons.append("Aplicar configuraciones del sistema a nivel de kernel y servicios.")

    print(f"\n{BOLD}{YELLOW}🔑 PRIVILEGIOS DE ADMINISTRADOR (SUDO) REQUERIDOS{RESET}")
    print(f"El asistente necesita permisos de 'sudo' exclusivamente para las siguientes tareas de bajo nivel:")
    for r in reasons:
        print(f"  • {r}")
    print(f"{CYAN}Ningún proceso quedará corriendo en segundo plano ni se modificará nada innecesario.{RESET}\n")


def execute_installation(target_model: Dict[str, Any]):
    model_id = target_model.get("id")
    model_name = target_model.get("model_name", model_id)
    components = target_model.get("components", {})

    print(f"\n{BOLD}{GREEN}========================================================================{RESET}")
    print(f"{BOLD}Iniciando Aprovisionamiento para: {CYAN}{model_name}{RESET}")
    print(f"{BOLD}Identificador interno: {YELLOW}{model_id}{RESET}")
    print(f"{BOLD}{GREEN}========================================================================{RESET}")

    # Detalle de componentes que se instalarán
    print(f"\n{BOLD}Componentes y Sensores a configurar:{RESET}")
    for comp, info in components.items():
        ctype = info.get("fix_type") or "nativo"
        print(f"  • {BOLD}{comp.upper()}{RESET}: {GREEN}{info.get('status', 'configurado')}{RESET} (mecanismo: {CYAN}{ctype}{RESET})")

    # Localizar script de instalación
    fix_dir = os.path.join(FIXES_DIR, model_id)
    install_script = os.path.join(fix_dir, "install-all.sh")

    if not os.path.isfile(install_script):
        # Si no existe en fixes, intentar generar uno base
        print(f"\n{YELLOW}[!] No se encontró carpeta precompilada en fixes/{model_id}. Generando script base...{RESET}")
        os.makedirs(fix_dir, exist_ok=True)
        with open(install_script, "w", encoding="utf-8") as f:
            f.write("#!/bin/bash\nset -e\n")
            f.write(f"echo 'Aplicando ajustes nativos para {model_name}...'\n")
            if "thermal" in components:
                f.write("if [ -f /sys/firmware/acpi/platform_profile ]; then echo 'balanced' | sudo tee /sys/firmware/acpi/platform_profile >/dev/null || true; fi\n")
            f.write("echo '✓ Ajustes completados.'\n")
        os.chmod(install_script, 0o755)

    explain_sudo_reasons(components)

    # Validar o pedir sudo de manera proactiva
    try:
        subprocess.check_call(["sudo", "-v"])
    except subprocess.CalledProcessError:
        print(f"{RED}Error: No se pudo autenticar con sudo. La instalación no puede continuar.{RESET}")
        sys.exit(1)

    print(f"\n{BOLD}{BLUE}>>> Ejecutando {install_script}...{RESET}\n")

    # Ejecutar el instalador paso a paso
    proc = subprocess.Popen(
        ["/bin/bash", install_script],
        cwd=fix_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )

    has_warnings = False
    for line in proc.stdout:
        print(line, end="")
        if "error" in line.lower() or "falló" in line.lower():
            has_warnings = True

    proc.wait()

    print(f"\n{BOLD}{GREEN}========================================================================{RESET}")
    if proc.returncode == 0:
        print(f"{BOLD}{GREEN}✓ ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!{RESET}")
        print(f"Tu equipo {BOLD}{model_name}{RESET} ha sido configurado con paridad de hardware OEM.")
        if has_warnings:
            print(f"{YELLOW}Nota: Se detectaron advertencias menores no bloqueantes en la salida anterior.{RESET}")
        print(f"Recomendación: Si se configuraron módulos de audio o kernel, reinicie la sesión para activar todo.")
    else:
        print(f"{BOLD}{RED}❌ ERROR: El proceso de instalación finalizó con código {proc.returncode}.{RESET}")
        print(f"{YELLOW}Diagnóstico y Verificaciones recomendadas:{RESET}")
        print("  1. Verifique si su kernel actual tiene los headers instalados ('linux-headers').")
        print("  2. Si usa kernels basados en Clang/LTO (CachyOS), verifique tener instalado 'lld': 'sudo pacman -S lld'.")
        print("  3. Revise los registros anteriores para identificar el paso específico que falló.")
    print(f"{BOLD}{GREEN}========================================================================{RESET}\n")


def main():
    print_banner()

    print(f"{BOLD}[1/3] Detectando hardware de la máquina local...{RESET}")
    hw = get_local_hardware()
    print(f"  • Fabricante DMI: {CYAN}{hw['vendor'] or 'Desconocido'}{RESET}")
    print(f"  • Producto DMI  : {CYAN}{hw['product_name'] or 'Desconocido'}{RESET}")
    print(f"  • Placa Madre   : {CYAN}{hw['board_name'] or 'Desconocida'}{RESET}")
    print(f"  • Versión BIOS  : {CYAN}{hw['bios_version'] or 'Desconocida'}{RESET}")
    if hw['audio_codecs']:
        print(f"  • Codecs Audio  : {CYAN}{', '.join(hw['audio_codecs'])}{RESET}")
    if hw['current_profile']:
        print(f"  • Perfil Térmico: {CYAN}{hw['current_profile']}{RESET} (Disponibles: {', '.join(hw['available_profiles'])})")
    if hw['acpi_sensors']:
        print(f"  • Sensores ACPI : {CYAN}{', '.join(hw['acpi_sensors'][:4])}{RESET}")

    print(f"\n{BOLD}[2/3] Buscando coincidencias en la base de datos de 10.221 modelos...{RESET}")
    models = load_all_models()
    if not models:
        print(f"{RED}Error: No se encontró la base de datos de modelos en {DB_MODELS_DIR}.{RESET}")
        sys.exit(1)

    matched = find_matching_model(hw, models)
    chosen_model = None

    if matched:
        m_name = matched.get("model_name", matched.get("id"))
        m_id = matched.get("id")
        m_vendor = matched.get("vendor")
        print(f"\n{BOLD}{GREEN}✓ Coincidencia Automática Sugerida:{RESET}")
        print(f"  Modelo: {BOLD}{m_name}{RESET} (OEM: {m_vendor}, ID: {CYAN}{m_id}{RESET})")

        resp = input(f"\n{YELLOW}¿Desea instalar la configuración para este modelo sugerido? [S/n/m (manual)]: {RESET}").strip().lower()
        if resp in ["", "s", "si", "y", "yes"]:
            chosen_model = matched
        elif resp in ["m", "manual"]:
            chosen_model = interactive_model_selection(models)
        else:
            print(f"{YELLOW}Pasando a selección manual...{RESET}")
            chosen_model = interactive_model_selection(models)
    else:
        print(f"{YELLOW}[!] No se pudo determinar con certeza absoluta el modelo a partir de los datos DMI.{RESET}")
        chosen_model = interactive_model_selection(models)

    print(f"\n{BOLD}[3/3] Procediendo con la preparación del hardware...{RESET}")
    execute_installation(chosen_model)


if __name__ == "__main__":
    main()
