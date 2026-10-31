#!/usr/bin/env bash
""":"
# ==============================================================================
# CodexCompatibilitas — Lanzador + Motor Políglota Todo-en-Uno (Bash + Python3)
# ==============================================================================
set -euo pipefail

# Resolver ruta real del archivo (incluso si se invoca mediante symlink)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# Verificar que python3 esté disponible en el sistema
if ! command -v python3 &>/dev/null; then
    echo "❌ Error: 'python3' no está instalado en el sistema." >&2
    exit 1
fi

export CODEX_INVOKED_DIR="$SCRIPT_DIR"
exec python3 "$SOURCE" "$@"
"""
"""
CodexCompatibilitas — Asistente Interactivo de Diagnóstico y Aprovisionamiento de Hardware OEM.

1. Analiza el hardware local (DMI extendido, PCI Subsystems, ACPI, Audio, Pantalla, Termales).
2. Usa caché indexada (models_index.json) para consultar +10.000 modelos en milisegundos.
3. Sugiere el modelo exacto detectado o permite elegir con navegación Atrás ('b') y Búsqueda ('/texto').
4. Ejecuta Pre-Flight Checks (linux-headers, Clang/LLD) antes de solicitar privilegios 'sudo'.
5. Aplica persistencia Zero-Daemon real (tmpfiles.d / udev) y soporta '--rollback'.
"""

import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

# ==============================================================================
# Resolución inteligente de rutas (funciona en la raíz o dentro de /scripts)
# ==============================================================================
CURRENT_FILE_DIR = os.path.dirname(os.path.abspath(__file__))
if os.path.isdir(os.path.join(CURRENT_FILE_DIR, "db", "models")):
    BASE_DIR = CURRENT_FILE_DIR
else:
    BASE_DIR = os.path.abspath(os.path.join(CURRENT_FILE_DIR, ".."))

DB_MODELS_DIR = os.path.join(BASE_DIR, "db", "models")
DB_INDEX_FILE = os.path.join(BASE_DIR, "db", "models_index.json")
FIXES_DIR = os.path.join(BASE_DIR, "fixes")
STATE_FILE = "/var/lib/codex-compatibilitas/state.json"
TMPFILES_THERMAL_CONF = "/etc/tmpfiles.d/codex-thermal.conf"

# Colores ANSI
BOLD = "\033[1m"
GREEN = "\033[32m"
BLUE = "\033[34m"
CYAN = "\033[36m"
YELLOW = "\033[33m"
RED = "\033[31m"
MAGENTA = "\033[35m"
RESET = "\033[0m"

# Valores basura comunes en tablas DMI de OEMs que deben ignorarse
INVALID_DMI_VALUES = {
    "",
    "to be filled by o.e.m.",
    "default string",
    "system product name",
    "system version",
    "not specified",
    "not applicable",
    "none",
    "unknown",
    "chassis serial number",
    "type1productconfigid",
}


def print_banner() -> None:
    print(f"\n{BOLD}{CYAN}========================================================================{RESET}")
    print(f"{BOLD}{MAGENTA}   CodexCompatibilitas 💻⚡ — Aprovisionamiento de Hardware OEM en Linux{RESET}")
    print(f"{CYAN}   Paridad de fábrica nativa: Audio DSP, Color OLED/IPS, Térmico y Teclados{RESET}")
    print(f"{CYAN}   Filosofía Zero-Daemon: 0% gasto de batería en reposo, 100% nativo.{RESET}")
    print(f"{BOLD}{CYAN}========================================================================{RESET}\n")


def read_sysfs(path: str, filter_dmi: bool = True) -> str:
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            val = f.read().strip()
            if filter_dmi and val.lower() in INVALID_DMI_VALUES:
                return ""
            return val
    except OSError:
        return ""


def get_local_hardware() -> Dict[str, Any]:
    vendor = read_sysfs("/sys/class/dmi/id/sys_vendor")
    product_name = read_sysfs("/sys/class/dmi/id/product_name")
    product_version = read_sysfs("/sys/class/dmi/id/product_version")
    product_sku = read_sysfs("/sys/class/dmi/id/product_sku")
    product_family = read_sysfs("/sys/class/dmi/id/product_family")
    board_name = read_sysfs("/sys/class/dmi/id/board_name")
    bios_version = read_sysfs("/sys/class/dmi/id/bios_version")
    chassis_type = read_sysfs("/sys/class/dmi/id/chassis_type", filter_dmi=False)

    # Audio codecs
    audio_codecs = []
    for cfile in glob.glob("/proc/asound/card*/codec#*"):
        try:
            with open(cfile, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    if line.startswith("Codec:"):
                        audio_codecs.append(line.split(":", 1)[1].strip())
                        break
        except OSError:
            pass

    # PCI Subsystem IDs (clave para amplificadores inteligentes Cirrus / TI y quirks de audio)
    pci_subsystems = set()
    for pdir in glob.glob("/sys/bus/pci/devices/*"):
        sub_ven = read_sysfs(os.path.join(pdir, "subsystem_vendor"), filter_dmi=False)
        sub_dev = read_sysfs(os.path.join(pdir, "subsystem_device"), filter_dmi=False)
        if sub_ven and sub_dev and sub_ven != "0x0000" and sub_dev != "0x0000":
            pci_subsystems.add(f"{sub_ven[2:]}:{sub_dev[2:]}".lower())

    # Platform profile
    current_profile = read_sysfs("/sys/firmware/acpi/platform_profile", filter_dmi=False)
    choices_raw = read_sysfs("/sys/firmware/acpi/platform_profile_choices", filter_dmi=False)
    available_profiles = choices_raw.split() if choices_raw else []

    # DPTF / Thermal / Audio ACPI sensors
    acpi_sensors = []
    for d in glob.glob("/sys/devices/platform/*"):
        bname = os.path.basename(d)
        if any(bname.startswith(p) for p in ("INT340", "INTC10", "PNP0C0B", "ACPI000E", "CSC3551", "TIAS2781")):
            acpi_sensors.append(bname)

    return {
        "vendor": vendor,
        "product_name": product_name,
        "product_version": product_version,
        "product_sku": product_sku,
        "product_family": product_family,
        "board_name": board_name,
        "bios_version": bios_version,
        "chassis_type": chassis_type,
        "audio_codecs": sorted(set(audio_codecs)),
        "pci_subsystems": sorted(pci_subsystems),
        "current_profile": current_profile,
        "available_profiles": available_profiles,
        "acpi_sensors": sorted(acpi_sensors),
    }


def extract_year(model: Dict[str, Any]) -> int:
    if isinstance(model.get("year"), int):
        return model["year"]
    text = f"{model.get('id', '')} {model.get('model_name', '')}"
    match = re.search(r"\b(201[3-9]|202[0-9])\b", text)
    if match:
        return int(match.group(1))
    return 2024


def load_all_models(rebuild_index: bool = False) -> List[Dict[str, Any]]:
    if not rebuild_index and os.path.isfile(DB_INDEX_FILE):
        try:
            with open(DB_INDEX_FILE, "r", encoding="utf-8") as f:
                cached = json.load(f)
                if isinstance(cached, list) and cached:
                    return cached
        except (OSError, json.JSONDecodeError):
            pass

    models: List[Dict[str, Any]] = []
    if not os.path.isdir(DB_MODELS_DIR):
        return models

    for root, _, files in os.walk(DB_MODELS_DIR):
        for f in sorted(files):
            if f.endswith(".json"):
                fpath = os.path.join(root, f)
                try:
                    with open(fpath, "r", encoding="utf-8") as jf:
                        data = json.load(jf)
                        if isinstance(data, dict) and "id" in data:
                            data["_json_path"] = os.path.relpath(fpath, BASE_DIR)
                            models.append(data)
                except (OSError, json.JSONDecodeError):
                    pass

    # Guardar índice rápido si el directorio db/ es escribible
    if models:
        try:
            with open(DB_INDEX_FILE, "w", encoding="utf-8") as idx_f:
                json.dump(models, idx_f, ensure_ascii=False)
        except OSError:
            pass

    return models


def find_matching_model(hw: Dict[str, Any], models: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    vendor_clean = hw["vendor"].lower()
    prod_clean = hw["product_name"].lower()
    ver_clean = hw["product_version"].lower()
    sku_clean = hw["product_sku"].lower()
    board_clean = hw["board_name"].lower()
    pci_subs = set(hw.get("pci_subsystems", []))

    probes = [p for p in (prod_clean, ver_clean, sku_clean, board_clean) if p]
    if not vendor_clean and not probes:
        return None

    best_match = None
    best_score = 0

    for m in models:
        m_vendor = m.get("vendor", "").lower()
        if vendor_clean and m_vendor:
            if m_vendor not in vendor_clean and vendor_clean not in m_vendor:
                continue

        score = 0
        m_id = m.get("id", "").lower()
        m_name = m.get("model_name", "").lower()
        m_sysid = m.get("system_id", "").lower()
        dmi_matches = [d.lower() for d in m.get("dmi_matches", []) if d]

        # 1. Coincidencias exactas en dmi_matches (+15 puntos) o parciales seguras (+10 puntos)
        for probe in (prod_clean, ver_clean, sku_clean, board_clean):
            if not probe:
                continue
            if probe in dmi_matches:
                score += 15
            elif len(probe) >= 4 and any(probe in d or d in probe for d in dmi_matches if len(d) >= 4):
                score += 10

        # 2. Coincidencia por system_id / PCI Subsystem ID (+12 puntos)
        if m_sysid:
            if m_sysid in (board_clean, prod_clean, sku_clean) or any(m_sysid in sub for sub in pci_subs):
                score += 12
            elif len(m_sysid) >= 4 and (m_sysid in board_clean or m_sysid in prod_clean):
                score += 8

        # 3. Coincidencia en el nombre del modelo o ID (solo si el token tiene >= 4 caracteres)
        for probe in (prod_clean, ver_clean, board_clean):
            if len(probe) >= 4:
                if probe == m_name:
                    score += 12
                elif re.search(rf"\b{re.escape(probe)}\b", m_name):
                    score += 7
                elif probe in m_id:
                    score += 5

        if score > best_score:
            best_score = score
            best_match = m

    return best_match if best_score >= 7 else None


def search_models_by_query(models: List[Dict[str, Any]], query: str) -> List[Dict[str, Any]]:
    tokens = [t.lower() for t in query.strip().split() if t]
    if not tokens:
        return []
    results = []
    for m in models:
        haystack = " ".join(
            [
                str(m.get("vendor", "")),
                str(m.get("family", "")),
                str(m.get("model_name", "")),
                str(m.get("id", "")),
                " ".join(m.get("dmi_matches", [])),
            ]
        ).lower()
        if all(t in haystack for t in tokens):
            results.append(m)
    return results


def ask_choice(prompt: str, options: List[str], allow_back: bool = False, allow_search: bool = True) -> Any:
    """
    Devuelve:
      - int >= 0: índice elegido
      - 'BACK': si el usuario presionó 'b'
      - ('SEARCH', query): si el usuario escribió '/texto'
    """
    print(f"\n{BOLD}{prompt}{RESET}")
    for i, opt in enumerate(options, 1):
        print(f"  {CYAN}[{i}]{RESET} {opt}")

    hints = [f"1-{len(options)}"]
    if allow_back:
        hints.append("'b' atrás")
    if allow_search:
        hints.append("'/texto' buscar")
    hints.append("'q' salir")
    hint_str = ", ".join(hints)

    while True:
        try:
            choice = input(f"\n{YELLOW}Seleccione ({hint_str}): {RESET}").strip()
            if choice.lower() == "q":
                print(f"{RED}Operación cancelada por el usuario.{RESET}")
                sys.exit(0)
            if allow_back and choice.lower() == "b":
                return "BACK"
            if allow_search and choice.startswith("/") and len(choice) > 1:
                return ("SEARCH", choice[1:].strip())

            val = int(choice)
            if 1 <= val <= len(options):
                return val - 1
            print(f"{RED}Número fuera de rango (debe ser entre 1 y {len(options)}).{RESET}")
        except ValueError:
            print(f"{RED}Entrada inválida. Ingrese un número o comando válido ({hint_str}).{RESET}")
        except (EOFError, KeyboardInterrupt):
            print(f"\n{RED}Operación cancelada. Saliendo...{RESET}")
            sys.exit(0)


def interactive_model_selection(models: List[Dict[str, Any]]) -> Dict[str, Any]:
    print(f"\n{BOLD}{BLUE}=== Selección Manual de Modelo ==={RESET}")
    print(f"{CYAN}Tip: Escribe '/nombre' en cualquier momento (ej. '/legion 7' o '/zephyrus') para buscar directo.{RESET}")

    vendors = sorted(set(m.get("vendor", "Otros") for m in models if m.get("vendor")))
    step = 1
    sel_vendor = ""
    sel_year = 2024
    sel_family = ""

    while True:
        if step == 1:
            res = ask_choice("Paso 1: Seleccione el Fabricante (OEM):", vendors, allow_back=False)
            if isinstance(res, tuple) and res[0] == "SEARCH":
                found = search_models_by_query(models, res[1])
                if not found:
                    print(f"{RED}No se encontraron modelos que coincidan con '{res[1]}'.{RESET}")
                    continue
                labels = [f"[{m.get('vendor')}] {m.get('model_name', m.get('id'))} ({m.get('id')})" for m in found[:30]]
                idx = ask_choice(f"Resultados de búsqueda para '{res[1]}' (mostrando hasta 30):", labels, allow_back=True)
                if idx == "BACK" or isinstance(idx, tuple):
                    continue
                return found[idx]
            sel_vendor = vendors[res]
            step = 2

        elif step == 2:
            models_v = [m for m in models if m.get("vendor") == sel_vendor]
            years = sorted(set(extract_year(m) for m in models_v), reverse=True)
            year_labels = [f"Año {y} ({sum(1 for m in models_v if extract_year(m) == y)} modelos)" for y in years]
            res = ask_choice(f"Paso 2: Seleccione el Año / Generación para {sel_vendor}:", year_labels, allow_back=True)
            if res == "BACK":
                step = 1
                continue
            if isinstance(res, tuple) and res[0] == "SEARCH":
                found = search_models_by_query(models_v, res[1])
                if not found:
                    print(f"{RED}Sin resultados en {sel_vendor} para '{res[1]}'.{RESET}")
                    continue
                labels = [f"{m.get('model_name', m.get('id'))} (ID: {m.get('id')})" for m in found[:30]]
                idx = ask_choice(f"Resultados en {sel_vendor}:", labels, allow_back=True)
                if idx == "BACK" or isinstance(idx, tuple):
                    continue
                return found[idx]
            sel_year = years[res]
            step = 3

        elif step == 3:
            models_y = [m for m in models if m.get("vendor") == sel_vendor and extract_year(m) == sel_year]
            families = sorted(set(m.get("family", "General") for m in models_y if m.get("family")))
            if len(families) > 1:
                res = ask_choice(
                    f"Paso 3: Seleccione la Familia / Serie ({sel_vendor} - {sel_year}):", families, allow_back=True
                )
                if res == "BACK":
                    step = 2
                    continue
                if isinstance(res, tuple) and res[0] == "SEARCH":
                    found = search_models_by_query(models_y, res[1])
                    if not found:
                        print(f"{RED}Sin resultados para '{res[1]}'.{RESET}")
                        continue
                    labels = [f"{m.get('model_name', m.get('id'))} (ID: {m.get('id')})" for m in found[:30]]
                    idx = ask_choice("Resultados:", labels, allow_back=True)
                    if idx == "BACK" or isinstance(idx, tuple):
                        continue
                    return found[idx]
                sel_family = families[res]
                step = 4
            else:
                sel_family = families[0] if families else ""
                step = 4

        elif step == 4:
            models_y = [m for m in models if m.get("vendor") == sel_vendor and extract_year(m) == sel_year]
            models_f = [m for m in models_y if m.get("family") == sel_family] if sel_family else models_y
            model_labels = [f"{m.get('model_name', m.get('id'))} (ID: {m.get('id')})" for m in models_f]
            res = ask_choice("Paso 4: Seleccione el Modelo exacto de laptop:", model_labels, allow_back=True)
            if res == "BACK":
                families = sorted(set(m.get("family", "General") for m in models_y if m.get("family")))
                step = 3 if len(families) > 1 else 2
                continue
            if isinstance(res, tuple) and res[0] == "SEARCH":
                found = search_models_by_query(models, res[1])
                if not found:
                    print(f"{RED}Sin resultados para '{res[1]}'.{RESET}")
                    continue
                labels = [f"[{m.get('vendor')}] {m.get('model_name', m.get('id'))} ({m.get('id')})" for m in found[:30]]
                idx = ask_choice("Resultados globales:", labels, allow_back=True)
                if idx == "BACK" or isinstance(idx, tuple):
                    continue
                return found[idx]
            return models_f[res]


def run_preflight_checks(components: Dict[str, Any]) -> bool:
    needs_module_build = any(
        isinstance(info, dict) and info.get("fix_type") in ("dkms", "kmod", "module")
        for info in components.values()
    )
    if not needs_module_build:
        return True

    print(f"\n{BOLD}{BLUE}🔍 Ejecutando verificaciones Pre-Vuelo (Kernel & Toolchain)...{RESET}")
    kernel_rel = os.uname().release
    build_dir = f"/lib/modules/{kernel_rel}/build"

    if not os.path.isdir(build_dir):
        print(f"{RED}❌ Faltan los headers del kernel en ejecución ({kernel_rel}).{RESET}")
        print(f"{YELLOW}   Directorio ausente: {build_dir}{RESET}")
        print(f"{YELLOW}   Instálalos antes de continuar (ej. 'sudo pacman -S linux-headers' o 'sudo apt install linux-headers-{kernel_rel}').{RESET}")
        return False

    proc_version = read_sysfs("/proc/version", filter_dmi=False).lower()
    if "clang" in proc_version:
        missing_llvm = [tool for tool in ("clang", "lld") if not shutil.which(tool)]
        if missing_llvm:
            print(f"{RED}❌ El kernel actual fue compilado con Clang/LLVM, pero faltan herramientas: {', '.join(missing_llvm)}{RESET}")
            print(f"{YELLOW}   Instálalas con: 'sudo pacman -S clang lld' o equivalente en tu distribución.{RESET}")
            return False

    print(f"{GREEN}✓ Entorno de compilación para kernel {kernel_rel} verificado correctamente.{RESET}")
    return True


def explain_sudo_reasons(components: Dict[str, Any]) -> None:
    reasons = []
    if "keyboard" in components or "keyboard_rgb" in components:
        reasons.append("Compilar e instalar el módulo nativo en /usr/lib/modules/ y configurar reglas udev del teclado.")
    if "thermal" in components:
        reasons.append("Configurar persistencia Zero-Daemon (systemd-tmpfiles) para ACPI platform_profile.")
    if "audio_amp" in components or "audio" in components:
        reasons.append("Instalar firmwares y topologías DSP de amplificadores de audio en /lib/firmware/.")

    if not reasons:
        reasons.append("Aplicar configuraciones de hardware a nivel de kernel, reglas udev y registrar estado.")

    print(f"\n{BOLD}{YELLOW}🔑 PRIVILEGIOS DE ADMINISTRADOR (SUDO) REQUERIDOS{RESET}")
    print("El asistente necesita permisos de 'sudo' exclusivamente para las siguientes tareas de bajo nivel:")
    for r in reasons:
        print(f"  • {r}")
    print(f"{CYAN}Ningún proceso quedará corriendo en segundo plano ni se modificará nada innecesario.{RESET}\n")


def record_installation_state(model_id: str, model_name: str, created_files: List[str]) -> None:
    state_payload = {
        "installed_at": datetime.now(timezone.utc).isoformat(),
        "model_id": model_id,
        "model_name": model_name,
        "created_files": created_files,
    }
    state_json = json.dumps(state_payload, indent=2, ensure_ascii=False)
    cmd = (
        f"sudo mkdir -p {os.path.dirname(STATE_FILE)} && "
        f"sudo tee {STATE_FILE} >/dev/null"
    )
    subprocess.run(cmd, input=state_json, text=True, shell=True, check=False)


def execute_rollback() -> None:
    if not os.path.isfile(STATE_FILE):
        print(f"{YELLOW}[!] No se encontró ningún estado de aprovisionamiento previo en {STATE_FILE}.{RESET}")
        sys.exit(0)

    try:
        with open(STATE_FILE, "r", encoding="utf-8") as f:
            state = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        print(f"{RED}Error leyendo archivo de estado: {e}{RESET}")
        sys.exit(1)

    model_id = state.get("model_id", "desconocido")
    model_name = state.get("model_name", model_id)
    created_files = state.get("created_files", [])

    print(f"\n{BOLD}{YELLOW}=== Revertir Aprovisionamiento (Rollback) ==={RESET}")
    print(f"Modelo instalado: {BOLD}{model_name}{RESET} ({CYAN}{model_id}{RESET})")
    print(f"Fecha de instalación: {state.get('installed_at', 'N/A')}")

    subprocess.check_call(["sudo", "-v"])

    # Si existe un uninstall.sh específico del modelo, ejecutarlo
    uninstall_script = os.path.join(FIXES_DIR, model_id, "uninstall.sh")
    if os.path.isfile(uninstall_script):
        print(f"{BLUE}>>> Ejecutando desinstalador específico {uninstall_script}...{RESET}")
        subprocess.run(["sudo", "/usr/bin/env", "bash", uninstall_script], cwd=os.path.dirname(uninstall_script), check=False)

    for fpath in created_files:
        if os.path.exists(fpath):
            print(f"  • Eliminando {fpath}...")
            subprocess.run(["sudo", "rm", "-f", fpath], check=False)

    subprocess.run(["sudo", "rm", "-f", STATE_FILE], check=False)
    print(f"\n{BOLD}{GREEN}✓ Rollback completado exitosamente.{RESET}\n")


def execute_installation(target_model: Dict[str, Any], dry_run: bool = False) -> None:
    model_id = target_model.get("id", "unknown")
    model_name = target_model.get("model_name", model_id)
    components = target_model.get("components", {})

    print(f"\n{BOLD}{GREEN}========================================================================{RESET}")
    print(f"{BOLD}Iniciando Aprovisionamiento para: {CYAN}{model_name}{RESET}")
    print(f"{BOLD}Identificador interno: {YELLOW}{model_id}{RESET}")
    print(f"{BOLD}{GREEN}========================================================================{RESET}")

    print(f"\n{BOLD}Componentes y Sensores a configurar:{RESET}")
    if components:
        for comp, info in components.items():
            ctype = info.get("fix_type") or "nativo"
            status = info.get("status", "configurado")
            print(f"  • {BOLD}{comp.upper()}{RESET}: {GREEN}{status}{RESET} (mecanismo: {CYAN}{ctype}{RESET})")
    else:
        print(f"  • {CYAN}Perfil genérico OEM (sin parches fuera del árbol requeridos){RESET}")

    if not run_preflight_checks(components):
        sys.exit(1)

    if dry_run:
        print(f"\n{YELLOW}[DRY-RUN] Simulación completada sin errores. No se modificó el sistema.{RESET}\n")
        return

    fix_dir = os.path.join(FIXES_DIR, model_id)
    install_script = os.path.join(fix_dir, "install-all.sh")
    created_files: List[str] = []

    if not os.path.isfile(install_script):
        print(f"\n{YELLOW}[!] No se encontró carpeta precompilada en fixes/{model_id}. Generando script Zero-Daemon...{RESET}")
        os.makedirs(fix_dir, exist_ok=True)
        with open(install_script, "w", encoding="utf-8") as f:
            f.write("#!/usr/bin/env bash\nset -euo pipefail\n")
            f.write(f"echo 'Aplicando ajustes nativos Zero-Daemon para {model_name}...'\n")
            if "thermal" in components:
                # Persistencia Zero-Daemon real mediante systemd-tmpfiles
                f.write(
                    f"if [ -f /sys/firmware/acpi/platform_profile ]; then\n"
                    f"    echo 'w /sys/firmware/acpi/platform_profile - - - - balanced' | sudo tee {TMPFILES_THERMAL_CONF} >/dev/null\n"
                    f"    sudo systemd-tmpfiles --create {TMPFILES_THERMAL_CONF} || true\n"
                    f"fi\n"
                )
            f.write("echo '✓ Ajustes nativos completados.'\n")
        os.chmod(install_script, 0o755)
        if "thermal" in components:
            created_files.append(TMPFILES_THERMAL_CONF)

    explain_sudo_reasons(components)

    try:
        subprocess.check_call(["sudo", "-v"])
    except subprocess.CalledProcessError:
        print(f"{RED}Error: No se pudo autenticar con sudo. La instalación no puede continuar.{RESET}")
        sys.exit(1)

    print(f"\n{BOLD}{BLUE}>>> Ejecutando {install_script}...{RESET}\n")

    proc = subprocess.Popen(
        ["/usr/bin/env", "bash", install_script],
        cwd=fix_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    has_warnings = False
    if proc.stdout:
        for line in proc.stdout:
            print(line, end="")
            if any(w in line.lower() for w in ("error", "falló", "warning", "warn")):
                has_warnings = True

    proc.wait()

    print(f"\n{BOLD}{GREEN}========================================================================{RESET}")
    if proc.returncode == 0:
        record_installation_state(model_id, model_name, created_files)
        print(f"{BOLD}{GREEN}✓ ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!{RESET}")
        print(f"Tu equipo {BOLD}{model_name}{RESET} ha sido configurado con paridad de hardware OEM.")
        if has_warnings:
            print(f"{YELLOW}Nota: Se detectaron advertencias menores no bloqueantes en la salida anterior.{RESET}")
        print(f"Estado registrado en: {CYAN}{STATE_FILE}{RESET} (puedes revertir con {YELLOW}--rollback{RESET}).")
        print("Recomendación: Si se configuraron módulos de audio o kernel, reinicie el equipo para activarlos.")
    else:
        print(f"{BOLD}{RED}❌ ERROR: El proceso de instalación finalizó con código {proc.returncode}.{RESET}")
        print(f"{YELLOW}Diagnóstico y verificaciones recomendadas:{RESET}")
        print("  1. Verifique si su kernel actual tiene los headers instalados ('linux-headers').")
        print("  2. Si usa kernels compilados con Clang/LTO (ej. CachyOS), verifique tener instalado 'lld' y 'clang'.")
        print("  3. Revise los registros anteriores para identificar el paso específico que falló.")
    print(f"{BOLD}{GREEN}========================================================================{RESET}\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="CodexCompatibilitas — Asistente Maestro Interactivo de Hardware OEM para Linux"
    )
    parser.add_argument("--model", type=str, help="ID exacto del modelo a instalar sin menú interactivo")
    parser.add_argument("--dry-run", action="store_true", help="Solo detectar y verificar pre-flight sin aplicar cambios")
    parser.add_argument("--rollback", action="store_true", help="Revertir el último aprovisionamiento registrado")
    parser.add_argument("--rebuild-index", action="store_true", help="Forzar reconstrucción del índice rápido de modelos")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    print_banner()

    if args.rollback:
        execute_rollback()
        return

    print(f"{BOLD}[1/3] Detectando hardware de la máquina local...{RESET}")
    hw = get_local_hardware()
    print(f"  • Fabricante DMI: {CYAN}{hw['vendor'] or 'Desconocido'}{RESET}")
    print(f"  • Producto DMI  : {CYAN}{hw['product_name'] or 'Desconocido'}{RESET}")
    if hw["product_version"]:
        print(f"  • Versión / Familia: {CYAN}{hw['product_version']} ({hw['product_family'] or 'N/A'}){RESET}")
    print(f"  • Placa Madre   : {CYAN}{hw['board_name'] or 'Desconocida'}{RESET}")
    print(f"  • Versión BIOS  : {CYAN}{hw['bios_version'] or 'Desconocida'}{RESET}")
    if hw["audio_codecs"]:
        print(f"  • Codecs Audio  : {CYAN}{', '.join(hw['audio_codecs'])}{RESET}")
    if hw["current_profile"]:
        print(
            f"  • Perfil Térmico: {CYAN}{hw['current_profile']}{RESET} "
            f"(Disponibles: {', '.join(hw['available_profiles'])})"
        )
    if hw["acpi_sensors"]:
        print(f"  • Sensores ACPI : {CYAN}{', '.join(hw['acpi_sensors'][:5])}{RESET}")

    print(f"\n{BOLD}[2/3] Consultando base de datos de modelos OEM...{RESET}")
    models = load_all_models(rebuild_index=args.rebuild_index)
    if not models:
        print(f"{RED}Error: No se encontró la base de datos de modelos en {DB_MODELS_DIR}.{RESET}")
        sys.exit(1)

    chosen_model: Optional[Dict[str, Any]] = None

    if args.model:
        chosen_model = next((m for m in models if m.get("id") == args.model), None)
        if not chosen_model:
            print(f"{RED}Error: El modelo con ID '{args.model}' no existe en la base de datos.{RESET}")
            sys.exit(1)
    else:
        matched = find_matching_model(hw, models)
        if matched:
            m_name = matched.get("model_name", matched.get("id"))
            m_id = matched.get("id")
            m_vendor = matched.get("vendor")
            print(f"\n{BOLD}{GREEN}✓ Coincidencia Automática Sugerida ({len(models)} modelos analizados):{RESET}")
            print(f"  Modelo: {BOLD}{m_name}{RESET} (OEM: {m_vendor}, ID: {CYAN}{m_id}{RESET})")

            try:
                resp = input(
                    f"\n{YELLOW}¿Desea instalar la configuración para este modelo sugerido? [S/n/m (manual)]: {RESET}"
                ).strip().lower()
            except (EOFError, KeyboardInterrupt):
                print(f"\n{RED}Operación cancelada.{RESET}")
                sys.exit(0)

            if resp in ("", "s", "si", "sí", "y", "yes"):
                chosen_model = matched
            else:
                print(f"{YELLOW}Pasando a selección manual...{RESET}")
                chosen_model = interactive_model_selection(models)
        else:
            print(f"{YELLOW}[!] No se pudo determinar con certeza absoluta el modelo a partir de los datos DMI.{RESET}")
            chosen_model = interactive_model_selection(models)

    print(f"\n{BOLD}[3/3] Procediendo con la preparación del hardware...{RESET}")
    execute_installation(chosen_model, dry_run=args.dry_run)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{RED}Ejecución interrumpida por el usuario.{RESET}")
        sys.exit(130)
