import os
import glob
from typing import List, Optional
from deepslop.models import ThermalProfile


class ThermalInspector:
    """Inspecciona y clasifica la arquitectura térmica y de ventiladores en Linux."""

    KNOWN_WMI_DRIVERS = [
        ("asus-nb-wmi", "ASUS WMI Thermal & Fan Policy"),
        ("thinkpad_acpi", "Lenovo ThinkPad ACPI Thermal & Fan Control"),
        ("dell-wmi-sysman", "Dell SMBIOS / WMI Thermal Management"),
        ("hp-wmi", "HP WMI Thermal & Performance Control"),
        ("ideapad_laptop", "Lenovo IdeaPad / Legion WMI Thermal Mode"),
    ]

    @staticmethod
    def inspect_system() -> ThermalProfile:
        # 1. Platform profile choices
        platform_profiles = []
        current_profile = None

        choices_path = "/sys/firmware/acpi/platform_profile_choices"
        if os.path.exists(choices_path):
            try:
                with open(choices_path, "r") as f:
                    platform_profiles = f.read().strip().split()
            except Exception:
                pass

        cur_path = "/sys/firmware/acpi/platform_profile"
        if os.path.exists(cur_path):
            try:
                with open(cur_path, "r") as f:
                    current_profile = f.read().strip()
            except Exception:
                pass

        # 2. Thermal zones
        thermal_zones = []
        for zone in sorted(glob.glob("/sys/class/thermal/thermal_zone*")):
            z_type_path = os.path.join(zone, "type")
            z_temp_path = os.path.join(zone, "temp")
            z_type = ""
            temp_c = ""
            if os.path.exists(z_type_path):
                try:
                    with open(z_type_path, "r") as f:
                        z_type = f.read().strip()
                except Exception:
                    pass
            if os.path.exists(z_temp_path):
                try:
                    with open(z_temp_path, "r") as f:
                        raw = f.read().strip()
                        if raw.isdigit():
                            temp_c = f"{int(raw)/1000.0:.1f}°C"
                except Exception:
                    pass
            base_name = os.path.basename(zone)
            thermal_zones.append(f"{base_name}: {z_type} ({temp_c})")

        # 3. Cooling devices / Fans
        cooling_devices = []
        for cdev in sorted(glob.glob("/sys/class/thermal/cooling_device*")):
            c_type_path = os.path.join(cdev, "type")
            c_max_path = os.path.join(cdev, "max_state")
            c_type = ""
            c_max = ""
            if os.path.exists(c_type_path):
                try:
                    with open(c_type_path, "r") as f:
                        c_type = f.read().strip()
                except Exception:
                    pass
            if os.path.exists(c_max_path):
                try:
                    with open(c_max_path, "r") as f:
                        c_max = f.read().strip()
                except Exception:
                    pass
            if "fan" in c_type.lower() or "tfn" in c_type.lower():
                cooling_devices.append(f"{os.path.basename(cdev)}: {c_type} (estados: 0-{c_max})")

        # 4. ACPI Thermal HIDs (DPTF, Fan, Sensors)
        acpi_thermal_hids = []
        for hid_file in glob.glob("/sys/bus/acpi/devices/*/hid"):
            try:
                with open(hid_file, "r") as f:
                    hid = f.read().strip()
                    # INT340x (Intel DPTF), INTC104x, PNP0C0B (ACPI Fan), ACPI000E
                    if any(k in hid for k in ["INT340", "INTC104", "PNP0C0B", "ACPI000E"]):
                        if hid not in acpi_thermal_hids:
                            acpi_thermal_hids.append(hid)
            except Exception:
                pass

        # 5. Interfaz WMI activa
        wmi_interface = None
        for mod, desc in ThermalInspector.KNOWN_WMI_DRIVERS:
            if os.path.exists(f"/sys/devices/platform/{mod}") or os.path.exists(f"/sys/module/{mod.replace('-', '_')}"):
                wmi_interface = f"{mod} ({desc})"
                break

        return ThermalProfile(
            platform_profiles=platform_profiles,
            current_profile=current_profile,
            thermal_zones=thermal_zones[:10],
            cooling_devices=cooling_devices,
            acpi_thermal_hids=sorted(acpi_thermal_hids),
            wmi_thermal_interface=wmi_interface,
            dptf_tuning_available=len(acpi_thermal_hids) > 0,
        )
