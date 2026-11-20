#!/usr/bin/env bash
# ==============================================================================
# CodexCompatibilitas — Instalador Standalone Zero-Clone & OS-Agnóstico
# Uso directo sin clonar:
#   wget -qO- https://raw.githubusercontent.com/stickyfran/CodexCompatibilitas/master/codex-setup.sh | bash
# ==============================================================================
set -euo pipefail

# Detectar directorio local si se ejecuta desde un archivo (y no desde pipe)
CODEX_LOCAL_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do
        DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done
    CODEX_LOCAL_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
fi

# Bootstrap OS-agnóstico de python3 si no está instalado
if ! command -v python3 &>/dev/null; then
    echo "⚠️  'python3' no está instalado. Es necesario para ejecutar CodexCompatibilitas."
    if [ -r /dev/tty ]; then
        read -r -p "¿Desea intentar instalar 'python3' automáticamente? [S/n]: " resp < /dev/tty || resp="n"
    else
        resp="n"
    fi
    case "${resp,,}" in
        ""|s|si|sí|y|yes)
            if command -v pacman &>/dev/null; then
                sudo pacman -S --needed --noconfirm python
            elif command -v apt-get &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y python3
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y python3
            elif command -v zypper &>/dev/null; then
                sudo zypper --non-interactive install python3
            elif command -v xbps-install &>/dev/null; then
                sudo xbps-install -Sy python3
            elif command -v apk &>/dev/null; then
                sudo apk add python3
            else
                echo "❌ No se pudo detectar un gestor de paquetes compatible. Instala 'python3' manualmente." >&2
                exit 1
            fi
            ;;
        *)
            echo "❌ Abortado. Instala 'python3' y vuelve a intentarlo." >&2
            exit 1
            ;;
    esac
fi

TMP_PY="$(mktemp /tmp/codex-setup.XXXXXX.py)"
trap 'rm -f "$TMP_PY"' EXIT

cat <<'__CODEX_PYTHON_EOF__' > "$TMP_PY"
"""
CodexCompatibilitas — Asistente Standalone Zero-Clone & OS-Agnóstico de Hardware OEM.

1. Funciona tanto en modo Zero-Clone (vía wget/curl | bash) como en repositorio local.
2. Analiza el hardware local (DMI extendido, PCI Subsystems, ACPI, Audio, Pantalla, Termales).
3. Descarga automáticamente el índice comprimido (~200 KB) de +10.000 modelos desde GitHub.
4. Detecta la distribución Linux (Arch/CachyOS, Debian/Ubuntu, Fedora, openSUSE, Void, Alpine)
   e instala dependencias de compilación (linux-headers, gcc/make, clang/lld, dkms) si faltan.
5. Pregunta interactivamente qué componentes instalar (Audio, Color, Térmico, Teclado/RGB).
6. Aplica persistencia Zero-Daemon real (systemd-tmpfiles) y soporta '--rollback'.
"""

import argparse
import glob
import gzip
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Tuple

# ==============================================================================
# Configuración de repositorio remoto y rutas locales
# ==============================================================================
REPO_OWNER = "stickyfran"
REPO_NAME = "CodexCompatibilitas"
REPO_BRANCH = "master"
RAW_BASE_URL = f"https://raw.githubusercontent.com/{REPO_OWNER}/{REPO_NAME}/{REPO_BRANCH}"
API_BASE_URL = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents"

INVOKED_DIR = os.environ.get("CODEX_LOCAL_DIR", "").strip()
if INVOKED_DIR and os.path.isdir(os.path.join(INVOKED_DIR, "db")):
    BASE_DIR: Optional[str] = INVOKED_DIR
elif INVOKED_DIR and os.path.isdir(os.path.join(INVOKED_DIR, "..", "db")):
    BASE_DIR = os.path.abspath(os.path.join(INVOKED_DIR, ".."))
elif os.path.isdir(os.path.join(os.getcwd(), "db", "models")):
    BASE_DIR = os.getcwd()
else:
    BASE_DIR = None  # Modo Standalone Zero-Clone

CACHE_DIR = os.path.join(os.path.expanduser("~"), ".cache", "codex-compatibilitas")
CACHE_GZ_INDEX = os.path.join(CACHE_DIR, "models_index.min.json.gz")
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


def print_banner(os_info: Dict[str, str]) -> None:
    mode_str = "Local" if BASE_DIR else "Standalone Zero-Clone (GitHub)"
    print(f"\n{BOLD}{CYAN}========================================================================{RESET}")
    print(f"{BOLD}{MAGENTA}   CodexCompatibilitas 💻⚡ — Aprovisionamiento de Hardware OEM en Linux{RESET}")
    print(f"{CYAN}   Paridad de fábrica nativa: Audio DSP, Color OLED/IPS, Térmico y Teclados{RESET}")
    print(f"{CYAN}   Modo: {mode_str} | OS: {os_info.get('pretty_name', 'Linux')}{RESET}")
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


# ==============================================================================
# Detección de Sistema Operativo y Gestor de Paquetes (OS-Agnóstico)
# ==============================================================================
def detect_os() -> Dict[str, str]:
    info = {"id": "linux", "id_like": "", "pretty_name": "Linux", "pkg_mgr": "unknown"}
    if os.path.isfile("/etc/os-release"):
        try:
            with open("/etc/os-release", "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    line = line.strip()
                    if "=" in line:
                        k, v = line.split("=", 1)
                        v = v.strip().strip('"').strip("'")
                        if k == "ID":
                            info["id"] = v.lower()
                        elif k == "ID_LIKE":
                            info["id_like"] = v.lower()
                        elif k == "PRETTY_NAME":
                            info["pretty_name"] = v
        except OSError:
            pass

    if shutil.which("pacman"):
        info["pkg_mgr"] = "pacman"
    elif shutil.which("apt-get"):
        info["pkg_mgr"] = "apt"
    elif shutil.which("dnf"):
        info["pkg_mgr"] = "dnf"
    elif shutil.which("zypper"):
        info["pkg_mgr"] = "zypper"
    elif shutil.which("xbps-install"):
        info["pkg_mgr"] = "xbps"
    elif shutil.which("apk"):
        info["pkg_mgr"] = "apk"

    return info


def get_arch_kernel_headers_pkg() -> str:
    """Detecta el paquete exacto de headers en Arch/CachyOS/EndeavourOS según el kernel activo."""
    rel = os.uname().release.lower()
    if "cachyos" in rel:
        # Ej: 6.12.x-2-cachyos -> linux-cachyos-headers
        m = re.search(r"(cachyos[a-z0-9-]*)", rel)
        if m:
            return f"linux-{m.group(1)}-headers"
        return "linux-cachyos-headers"
    if "zen" in rel:
        return "linux-zen-headers"
    if "lts" in rel:
        return "linux-lts-headers"
    if "hardened" in rel:
        return "linux-hardened-headers"
    return "linux-headers"


def build_dep_install_cmd(os_info: Dict[str, str], needs_headers: bool, needs_clang: bool, needs_gcc: bool) -> Optional[List[str]]:
    pkg_mgr = os_info.get("pkg_mgr", "unknown")
    rel = os.uname().release
    pkgs: List[str] = []

    if pkg_mgr == "pacman":
        if needs_headers:
            pkgs.append(get_arch_kernel_headers_pkg())
        if needs_gcc:
            pkgs.extend(["base-devel", "dkms"])
        if needs_clang:
            pkgs.extend(["clang", "lld", "llvm"])
        return ["sudo", "pacman", "-S", "--needed", "--noconfirm"] + pkgs if pkgs else None

    if pkg_mgr == "apt":
        if needs_headers:
            pkgs.append(f"linux-headers-{rel}")
        if needs_gcc:
            pkgs.extend(["build-essential", "dkms"])
        if needs_clang:
            pkgs.extend(["clang", "lld", "llvm"])
        if not pkgs:
            return None
        return ["sudo", "bash", "-c", f"apt-get update && apt-get install -y {' '.join(pkgs)}"]

    if pkg_mgr == "dnf":
        if needs_headers:
            pkgs.append(f"kernel-devel-{rel}")
        if needs_gcc:
            pkgs.extend(["gcc", "make", "dkms"])
        if needs_clang:
            pkgs.extend(["clang", "lld", "llvm"])
        return ["sudo", "dnf", "install", "-y"] + pkgs if pkgs else None

    if pkg_mgr == "zypper":
        if needs_headers:
            pkgs.append("kernel-default-devel")
        if needs_gcc:
            pkgs.extend(["gcc", "make", "dkms"])
        if needs_clang:
            pkgs.extend(["clang", "lld", "llvm"])
        return ["sudo", "zypper", "--non-interactive", "install"] + pkgs if pkgs else None

    if pkg_mgr == "xbps":
        if needs_headers:
            pkgs.append("linux-headers")
        if needs_gcc:
            pkgs.extend(["base-devel", "dkms"])
        if needs_clang:
            pkgs.extend(["clang", "lld"])
        return ["sudo", "xbps-install", "-Sy"] + pkgs if pkgs else None

    if pkg_mgr == "apk":
        if needs_headers:
            pkgs.append("linux-headers")
        if needs_gcc:
            pkgs.append("build-base")
        if needs_clang:
            pkgs.extend(["clang", "lld"])
        return ["sudo", "apk", "add"] + pkgs if pkgs else None

    return None


# ==============================================================================
# Detección de Hardware Local
# ==============================================================================
def get_local_hardware() -> Dict[str, Any]:
    vendor = read_sysfs("/sys/class/dmi/id/sys_vendor")
    product_name = read_sysfs("/sys/class/dmi/id/product_name")
    product_version = read_sysfs("/sys/class/dmi/id/product_version")
    product_sku = read_sysfs("/sys/class/dmi/id/product_sku")
    product_family = read_sysfs("/sys/class/dmi/id/product_family")
    board_name = read_sysfs("/sys/class/dmi/id/board_name")
    bios_version = read_sysfs("/sys/class/dmi/id/bios_version")
    chassis_type = read_sysfs("/sys/class/dmi/id/chassis_type", filter_dmi=False)

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

    pci_subsystems = set()
    for pdir in glob.glob("/sys/bus/pci/devices/*"):
        sub_ven = read_sysfs(os.path.join(pdir, "subsystem_vendor"), filter_dmi=False)
        sub_dev = read_sysfs(os.path.join(pdir, "subsystem_device"), filter_dmi=False)
        if sub_ven and sub_dev and sub_ven != "0x0000" and sub_dev != "0x0000":
            pci_subsystems.add(f"{sub_ven[2:]}:{sub_dev[2:]}".lower())

    current_profile = read_sysfs("/sys/firmware/acpi/platform_profile", filter_dmi=False)
    choices_raw = read_sysfs("/sys/firmware/acpi/platform_profile_choices", filter_dmi=False)
    available_profiles = choices_raw.split() if choices_raw else []

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


# ==============================================================================
# Carga de Catálogo (Local o Descarga Automática ~200 KB desde GitHub)
# ==============================================================================
def fetch_url_bytes(url: str, timeout: int = 20) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "CodexCompatibilitas-Setup/2.0"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read()


def load_all_models(rebuild_index: bool = False) -> List[Dict[str, Any]]:
    # 1. Intentar índice comprimido local si estamos dentro del repo
    if BASE_DIR:
        local_gz = os.path.join(BASE_DIR, "db", "models_index.min.json.gz")
        if not rebuild_index and os.path.isfile(local_gz):
            try:
                with gzip.open(local_gz, "rb") as f:
                    data = json.loads(f.read().decode("utf-8"))
                    if isinstance(data, list) and data:
                        return data
            except (OSError, json.JSONDecodeError):
                pass

        # Reconstruir desde db/models/ si existe
        local_models_dir = os.path.join(BASE_DIR, "db", "models")
        if os.path.isdir(local_models_dir):
            models: List[Dict[str, Any]] = []
            for root, _, files in os.walk(local_models_dir):
                for fname in sorted(files):
                    if fname.endswith(".json"):
                        try:
                            with open(os.path.join(root, fname), "r", encoding="utf-8") as jf:
                                m = json.load(jf)
                                if isinstance(m, dict) and "id" in m:
                                    models.append({
                                        "id": m.get("id", ""),
                                        "vendor": m.get("vendor", ""),
                                        "family": m.get("family", ""),
                                        "model_name": m.get("model_name", ""),
                                        "year": m.get("year"),
                                        "system_id": m.get("system_id", ""),
                                        "dmi_matches": m.get("dmi_matches", []),
                                        "components": m.get("components", {}),
                                    })
                        except (OSError, json.JSONDecodeError):
                            pass
            if models:
                try:
                    raw = json.dumps(models, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
                    with gzip.open(local_gz, "wb", compresslevel=9) as out:
                        out.write(raw)
                except OSError:
                    pass
                return models

    # 2. Modo Standalone Zero-Clone: usar caché local o descargar ~200 KB desde GitHub
    if not rebuild_index and os.path.isfile(CACHE_GZ_INDEX):
        try:
            with gzip.open(CACHE_GZ_INDEX, "rb") as f:
                cached = json.loads(f.read().decode("utf-8"))
                if isinstance(cached, list) and cached:
                    return cached
        except (OSError, json.JSONDecodeError):
            pass

    url = f"{RAW_BASE_URL}/db/models_index.min.json.gz"
    print(f"  {CYAN}↓ Descargando catálogo maestro de 10.221 modelos (~200 KB) desde GitHub...{RESET}")
    try:
        gz_bytes = fetch_url_bytes(url)
        os.makedirs(CACHE_DIR, exist_ok=True)
        with open(CACHE_GZ_INDEX, "wb") as out:
            out.write(gz_bytes)
        return json.loads(gzip.decompress(gz_bytes).decode("utf-8"))
    except Exception as e:
        print(f"{RED}❌ Error descargando el catálogo desde {url}: {e}{RESET}")
        return []


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

        for probe in (prod_clean, ver_clean, sku_clean, board_clean):
            if not probe:
                continue
            if probe in dmi_matches:
                score += 15
            elif len(probe) >= 4 and any(probe in d or d in probe for d in dmi_matches if len(d) >= 4):
                score += 10

        if m_sysid:
            if m_sysid in (board_clean, prod_clean, sku_clean) or any(m_sysid in sub for sub in pci_subs):
                score += 12
            elif len(m_sysid) >= 4 and (m_sysid in board_clean or m_sysid in prod_clean):
                score += 8

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


# ==============================================================================
# Interacción con el Usuario
# ==============================================================================
def ask_yes_no(prompt: str, default_yes: bool = True, auto_yes: bool = False) -> bool:
    if auto_yes:
        return default_yes
    suffix = "[S/n]" if default_yes else "[s/N]"
    try:
        resp = input(f"{YELLOW}{prompt} {suffix}: {RESET}").strip().lower()
    except (EOFError, KeyboardInterrupt):
        print(f"\n{RED}Operación cancelada.{RESET}")
        sys.exit(0)
    if not resp:
        return default_yes
    return resp in ("s", "si", "sí", "y", "yes")


def ask_choice(prompt: str, options: List[str], allow_back: bool = False, allow_search: bool = True) -> Any:
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
    print(f"{CYAN}Tip: Escribe '/nombre' en cualquier momento (ej. '/legion 7' o '/s5506ma') para buscar directo.{RESET}")

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


def select_components_interactively(components: Dict[str, Any], auto_yes: bool = False) -> Dict[str, Any]:
    if not components or auto_yes:
        return components

    print(f"\n{BOLD}Componentes y Sensores disponibles para este modelo:{RESET}")
    for comp, info in components.items():
        ctype = info.get("fix_type") or "nativo" if isinstance(info, dict) else "nativo"
        status = info.get("status", "configurado") if isinstance(info, dict) else str(info)
        print(f"  • {BOLD}{comp.upper()}{RESET}: {GREEN}{status}{RESET} (mecanismo: {CYAN}{ctype}{RESET})")

    try:
        mode = input(
            f"\n{YELLOW}¿Instalar TODOS los componentes [S], elegir UNO POR UNO [e], o cancelar [n]? [S/e/n]: {RESET}"
        ).strip().lower()
    except (EOFError, KeyboardInterrupt):
        print(f"\n{RED}Operación cancelada.{RESET}")
        sys.exit(0)

    if mode in ("n", "no", "q"):
        print(f"{RED}Instalación cancelada por el usuario.{RESET}")
        sys.exit(0)
    if mode not in ("e", "elegir", "m", "manual"):
        return components

    selected: Dict[str, Any] = {}
    print(f"\n{BOLD}{BLUE}=== Selección Componente por Componente ==={RESET}")
    for comp, info in components.items():
        ctype = info.get("fix_type") or "nativo" if isinstance(info, dict) else "nativo"
        if ask_yes_no(f"  ¿Instalar/configurar {BOLD}{comp.upper()}{RESET} ({ctype})?", default_yes=True):
            selected[comp] = info

    if not selected:
        print(f"{YELLOW}No se seleccionó ningún componente. Saliendo sin modificar el sistema.{RESET}")
        sys.exit(0)
    return selected


# ==============================================================================
# Pre-Flight Check + Instalador Automático OS-Agnóstico de Dependencias
# ==============================================================================
def run_preflight_and_install_deps(
    components: Dict[str, Any], os_info: Dict[str, str], dry_run: bool = False, auto_yes: bool = False
) -> bool:
    needs_module_build = any(
        isinstance(info, dict) and info.get("fix_type") in ("dkms", "kmod", "module", "asus-nb-wmi")
        for info in components.values()
    )
    if not needs_module_build:
        return True

    print(f"\n{BOLD}{BLUE}🔍 Verificando dependencias de compilación (Kernel & Toolchain)...{RESET}")
    kernel_rel = os.uname().release
    build_dir = f"/lib/modules/{kernel_rel}/build"
    proc_version = read_sysfs("/proc/version", filter_dmi=False).lower()

    missing_headers = not os.path.isdir(build_dir)
    missing_gcc = not (shutil.which("gcc") and shutil.which("make"))
    missing_clang = "clang" in proc_version and not (shutil.which("clang") and shutil.which("lld"))

    if not (missing_headers or missing_gcc or missing_clang):
        print(f"{GREEN}✓ Entorno de compilación para kernel {kernel_rel} listo.{RESET}")
        return True

    if missing_headers:
        print(f"  {YELLOW}• Faltan los headers del kernel ({kernel_rel}): {build_dir}{RESET}")
    if missing_gcc:
        print(f"  {YELLOW}• Faltan herramientas base de compilación (gcc / make).{RESET}")
    if missing_clang:
        print(f"  {YELLOW}• Kernel compilado con Clang/LTO detectado: faltan 'clang' y/o 'lld'.{RESET}")

    install_cmd = build_dep_install_cmd(os_info, missing_headers, missing_clang, missing_gcc)
    if not install_cmd:
        print(f"{RED}❌ No se pudo determinar el comando de instalación para tu OS ({os_info['pretty_name']}).{RESET}")
        print(f"{YELLOW}   Instala manualmente los headers del kernel y herramientas de compilación.{RESET}")
        return False

    cmd_str = " ".join(install_cmd)
    if dry_run:
        print(f"{CYAN}[DRY-RUN] Se ofrecería instalar dependencias con: {cmd_str}{RESET}")
        return True

    print(f"\n{BOLD}Comando detectado para {os_info['pretty_name']}:{RESET}")
    print(f"  {CYAN}{cmd_str}{RESET}")
    if ask_yes_no("¿Desea descargar e instalar automáticamente estas dependencias ahora?", default_yes=True, auto_yes=auto_yes):
        try:
            subprocess.check_call(install_cmd)
            print(f"{GREEN}✓ Dependencias de compilación instaladas correctamente.{RESET}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"{RED}❌ Error instalando dependencias (código {e.returncode}).{RESET}")
            return False
    else:
        print(f"{YELLOW}⚠️  Continuando sin instalar dependencias (la compilación de módulos podría fallar).{RESET}")
        return True


# ==============================================================================
# Descarga Remota de Fixes (Zero-Clone)
# ==============================================================================
def download_github_dir(api_url: str, dest_dir: str) -> bool:
    try:
        raw = fetch_url_bytes(api_url)
        items = json.loads(raw.decode("utf-8"))
        if not isinstance(items, list):
            return False
        os.makedirs(dest_dir, exist_ok=True)
        for item in items:
            itype = item.get("type")
            name = item.get("name", "")
            if itype == "file" and item.get("download_url"):
                content = fetch_url_bytes(item["download_url"])
                fpath = os.path.join(dest_dir, name)
                with open(fpath, "wb") as f:
                    f.write(content)
                if name.endswith(".sh"):
                    os.chmod(fpath, 0o755)
            elif itype == "dir" and item.get("url"):
                download_github_dir(item["url"], os.path.join(dest_dir, name))
        return True
    except Exception:
        return False


def explain_sudo_reasons(components: Dict[str, Any]) -> None:
    reasons = []
    if "keyboard" in components or "keyboard_rgb" in components:
        reasons.append("Compilar/instalar módulos nativos en /usr/lib/modules/ y configurar reglas udev del teclado.")
    if "thermal" in components:
        reasons.append("Configurar persistencia Zero-Daemon (systemd-tmpfiles) para ACPI platform_profile.")
    if "audio_amp" in components or "audio" in components:
        reasons.append("Instalar perfiles DSP de PipeWire / firmwares de amplificadores de audio.")
    if "display_color" in components or "display" in components:
        reasons.append("Instalar perfiles de color calibrados de fábrica (.icm/.icc) en el sistema.")

    if not reasons:
        reasons.append("Aplicar configuraciones de hardware a nivel de kernel, reglas udev y registrar estado.")

    print(f"\n{BOLD}{YELLOW}🔑 PRIVILEGIOS DE ADMINISTRADOR (SUDO) REQUERIDOS{RESET}")
    print("El asistente necesita permisos de 'sudo' exclusivamente para:")
    for r in reasons:
        print(f"  • {r}")
    print(f"{CYAN}Ningún proceso quedará corriendo en segundo plano (arquitectura Zero-Daemon).{RESET}\n")


def record_installation_state(model_id: str, model_name: str, created_files: List[str]) -> None:
    state_payload = {
        "installed_at": datetime.now(timezone.utc).isoformat(),
        "model_id": model_id,
        "model_name": model_name,
        "created_files": created_files,
    }
    state_json = json.dumps(state_payload, indent=2, ensure_ascii=False)
    cmd = f"sudo mkdir -p {os.path.dirname(STATE_FILE)} && sudo tee {STATE_FILE} >/dev/null"
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

    if BASE_DIR:
        uninstall_script = os.path.join(BASE_DIR, "fixes", model_id, "uninstall.sh")
        if os.path.isfile(uninstall_script):
            print(f"{BLUE}>>> Ejecutando desinstalador específico {uninstall_script}...{RESET}")
            subprocess.run(["sudo", "/usr/bin/env", "bash", uninstall_script], cwd=os.path.dirname(uninstall_script), check=False)

    for fpath in created_files:
        if os.path.exists(fpath):
            print(f"  • Eliminando {fpath}...")
            subprocess.run(["sudo", "rm", "-f", fpath], check=False)

    subprocess.run(["sudo", "rm", "-f", STATE_FILE], check=False)
    print(f"\n{BOLD}{GREEN}✓ Rollback completado exitosamente.{RESET}\n")


def execute_installation(
    target_model: Dict[str, Any], os_info: Dict[str, str], dry_run: bool = False, auto_yes: bool = False
) -> None:
    model_id = target_model.get("id", "unknown")
    model_name = target_model.get("model_name", model_id)
    all_components = target_model.get("components", {})

    print(f"\n{BOLD}{GREEN}========================================================================{RESET}")
    print(f"{BOLD}Preparando Aprovisionamiento para: {CYAN}{model_name}{RESET}")
    print(f"{BOLD}Identificador interno: {YELLOW}{model_id}{RESET}")
    print(f"{BOLD}{GREEN}========================================================================{RESET}")

    components = select_components_interactively(all_components, auto_yes=auto_yes)

    if not run_preflight_and_install_deps(components, os_info, dry_run=dry_run, auto_yes=auto_yes):
        sys.exit(1)

    if dry_run:
        print(f"\n{YELLOW}[DRY-RUN] Simulación completada sin errores. No se modificó el sistema.{RESET}\n")
        return

    temp_work_dir: Optional[str] = None
    created_files: List[str] = []

    if BASE_DIR and os.path.isfile(os.path.join(BASE_DIR, "fixes", model_id, "install-all.sh")):
        fix_dir = os.path.join(BASE_DIR, "fixes", model_id)
    else:
        temp_work_dir = tempfile.mkdtemp(prefix=f"codex-fix-{model_id}-")
        fix_dir = temp_work_dir
        print(f"\n{CYAN}↓ Buscando parches específicos para '{model_id}' en GitHub...{RESET}")
        downloaded = download_github_dir(f"{API_BASE_URL}/fixes/{model_id}", fix_dir)
        if not downloaded or not os.path.isfile(os.path.join(fix_dir, "install-all.sh")):
            print(f"{YELLOW}[!] Sin carpeta precompilada remota. Generando script Zero-Daemon nativo...{RESET}")
            install_script = os.path.join(fix_dir, "install-all.sh")
            with open(install_script, "w", encoding="utf-8") as f:
                f.write("#!/usr/bin/env bash\nset -euo pipefail\n")
                f.write(f"echo 'Aplicando ajustes nativos Zero-Daemon para {model_name}...'\n")
                if "thermal" in components:
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

    install_script = os.path.join(fix_dir, "install-all.sh")
    explain_sudo_reasons(components)

    try:
        subprocess.check_call(["sudo", "-v"])
    except subprocess.CalledProcessError:
        print(f"{RED}Error: No se pudo autenticar con sudo. La instalación no puede continuar.{RESET}")
        if temp_work_dir:
            shutil.rmtree(temp_work_dir, ignore_errors=True)
        sys.exit(1)

    print(f"\n{BOLD}{BLUE}>>> Ejecutando aprovisionamiento para {model_name}...{RESET}\n")

    env = os.environ.copy()
    env["CODEX_SELECTED_COMPONENTS"] = ",".join(components.keys())

    proc = subprocess.Popen(
        ["/usr/bin/env", "bash", install_script],
        cwd=fix_dir,
        env=env,
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

    if temp_work_dir:
        shutil.rmtree(temp_work_dir, ignore_errors=True)

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
        print(f"{YELLOW}Revise los registros anteriores para identificar el paso específico que falló.{RESET}")
    print(f"{BOLD}{GREEN}========================================================================{RESET}\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="CodexCompatibilitas — Asistente Standalone Zero-Clone & OS-Agnóstico de Hardware OEM"
    )
    parser.add_argument("--model", type=str, help="ID exacto del modelo a instalar sin menú interactivo")
    parser.add_argument("--dry-run", action="store_true", help="Solo detectar y verificar pre-flight sin aplicar cambios")
    parser.add_argument("--rollback", action="store_true", help="Revertir el último aprovisionamiento registrado")
    parser.add_argument("--rebuild-index", action="store_true", help="Forzar reconstrucción/descarga del índice de modelos")
    parser.add_argument("-y", "--yes", action="store_true", help="Confirmar automáticamente todas las preguntas")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    os_info = detect_os()
    print_banner(os_info)

    if args.rollback:
        execute_rollback()
        return

    print(f"{BOLD}[1/3] Detectando hardware de la máquina local...{RESET}")
    hw = get_local_hardware()
    print(f"  • Sistema OS    : {CYAN}{os_info['pretty_name']} (gestor: {os_info['pkg_mgr']}){RESET}")
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

    print(f"\n{BOLD}[2/3] Consultando catálogo maestro de modelos OEM...{RESET}")
    models = load_all_models(rebuild_index=args.rebuild_index)
    if not models:
        print(f"{RED}Error: No se pudo cargar el catálogo de modelos.{RESET}")
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

            if args.yes or ask_yes_no("¿Es este tu dispositivo y deseas continuar con él?", default_yes=True):
                chosen_model = matched
            else:
                print(f"{YELLOW}Pasando a selección manual...{RESET}")
                chosen_model = interactive_model_selection(models)
        else:
            print(f"{YELLOW}[!] No se pudo determinar con certeza absoluta el modelo a partir de los datos DMI.{RESET}")
            chosen_model = interactive_model_selection(models)

    print(f"\n{BOLD}[3/3] Preparación e instalación de componentes...{RESET}")
    execute_installation(chosen_model, os_info, dry_run=args.dry_run, auto_yes=args.yes)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{RED}Ejecución interrumpida por el usuario.{RESET}")
        sys.exit(130)
__CODEX_PYTHON_EOF__

export CODEX_LOCAL_DIR
if [ ! -t 0 ] && [ -r /dev/tty ]; then
    python3 "$TMP_PY" "$@" < /dev/tty
else
    python3 "$TMP_PY" "$@"
fi
