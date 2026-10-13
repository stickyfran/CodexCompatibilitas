import os
import subprocess
import glob
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field


class LocalHardwareProfile(BaseModel):
    vendor: str
    product_name: str
    board_name: str
    bios_version: str
    pci_subsystems: List[str] = Field(default_factory=list)
    audio_codecs: List[str] = Field(default_factory=list)
    display_edids: List[str] = Field(default_factory=list)
    acpi_devices: List[str] = Field(default_factory=list)


def _read_sysfs(path: str) -> str:
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            return f.read().strip()
    except Exception:
        return ""


def probe_local_system() -> LocalHardwareProfile:
    # 1. DMI info
    vendor = _read_sysfs("/sys/class/dmi/id/sys_vendor")
    product_name = _read_sysfs("/sys/class/dmi/id/product_name")
    board_name = _read_sysfs("/sys/class/dmi/id/board_name")
    bios_version = _read_sysfs("/sys/class/dmi/id/bios_version")

    # 2. PCI Subsystems
    pci_subsystems = []
    try:
        lspci_out = subprocess.check_output(["lspci", "-nn"], text=True)
        for line in lspci_out.splitlines():
            # Buscamos audio, gpu, etc
            if "Audio" in line or "Multimedia" in line:
                pci_subsystems.append(line.strip())
    except Exception:
        pass

    # 3. Audio Codecs
    audio_codecs = []
    for codec_path in glob.glob("/proc/asound/card*/codec#*"):
        with open(codec_path, "r", errors="ignore") as f:
            for line in f:
                if line.startswith("Codec:"):
                    audio_codecs.append(line.split(":", 1)[1].strip())
                    break

    # 4. Display EDID hashes / strings
    display_edids = []
    for edid_path in glob.glob("/sys/class/drm/*/edid"):
        try:
            with open(edid_path, "rb") as f:
                raw = f.read()
                if len(raw) >= 128:
                    # Extraer 4 caracteres ASCII de modelo si existen
                    ascii_str = "".join(chr(b) for b in raw if 32 <= b <= 126)
                    display_edids.append(ascii_str[:20])
        except Exception:
            pass

    # 5. ACPI HIDs
    acpi_devices = []
    for hid_path in glob.glob("/sys/bus/acpi/devices/*/hid"):
        hid = _read_sysfs(hid_path)
        if hid and hid not in acpi_devices:
            acpi_devices.append(hid)

    return LocalHardwareProfile(
        vendor=vendor,
        product_name=product_name,
        board_name=board_name,
        bios_version=bios_version,
        pci_subsystems=pci_subsystems,
        audio_codecs=audio_codecs,
        display_edids=display_edids,
        acpi_devices=acpi_devices,
    )
