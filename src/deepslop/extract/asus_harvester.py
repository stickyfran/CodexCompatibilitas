import os
import json
import asyncio
import httpx
from typing import Dict, List, Optional
from rich.console import Console

from deepslop.models import DriverRef, DriverPackRef

console = Console()


class AsusApiHarvester:
    """Extrae la lista completa y categorizada de drivers oficiales directamente de la API de ASUS."""

    BASE_URL = "https://rog.asus.com/support/webapi/product/GetPDDrivers"

    def __init__(self, output_dir: str):
        self.output_dir = output_dir
        os.makedirs(self.output_dir, exist_ok=True)

    async def harvest_model_drivers(self, model_code: str) -> List[DriverRef]:
        cache_file = os.path.join(self.output_dir, f"{model_code.lower()}_drivers.json")
        if os.path.exists(cache_file):
            try:
                with open(cache_file, "r") as f:
                    data = json.load(f)
                    return [DriverRef(**d) for d in data]
            except Exception:
                pass

        params = {
            "website": "global",
            "model": model_code,
            "pdhashedid": "dummy",
            "cpu": model_code,
            "osid": "52",  # Windows 11 64-bit
        }
        headers = {"User-Agent": "Mozilla/5.0"}

        drivers: List[DriverRef] = []
        try:
            async with httpx.AsyncClient(timeout=15.0, headers=headers) as client:
                resp = await client.get(self.BASE_URL, params=params)
                if resp.status_code != 200:
                    return []
                data = resp.json()

            if data.get("Status") != "SUCCESS":
                return []

            for cat_obj in data.get("Result", {}).get("Obj", []):
                for file_info in cat_obj.get("Files", []):
                    title = file_info.get("Title", "").strip()
                    version = file_info.get("Version", "").strip()
                    dl_url = file_info.get("DownloadUrl", {}).get("Global") or file_info.get("DownloadUrl", {}).get("China", "")
                    size_str = file_info.get("FileSize", "0")
                    release_date = file_info.get("ReleaseDate", "")

                    if not dl_url:
                        continue

                    # Determinar categoría
                    cat = "utility"
                    lower_t = title.lower()
                    if "audio" in lower_t or "realtek" in lower_t or "smart sound" in lower_t:
                        cat = "audio"
                    elif "vga" in lower_t or "graphic" in lower_t:
                        cat = "display"
                    elif "touchpad" in lower_t:
                        cat = "touchpad"
                    elif "wlan" in lower_t or "wifi" in lower_t or "lan" in lower_t or "bluetooth" in lower_t:
                        cat = "network"
                    elif "chipset" in lower_t or "tuning" in lower_t or "dtt" in lower_t or "serial io" in lower_t:
                        cat = "chipset_thermal"
                    elif "splendid" in lower_t:
                        cat = "color"

                    driver = DriverRef(
                        category=cat,
                        name=title,
                        version=version,
                        url=dl_url,
                        release_date=release_date,
                    )
                    drivers.append(driver)

            # Guardar en caché
            with open(cache_file, "w") as f:
                json.dump([d.model_dump() for d in drivers], f, indent=2)

        except Exception as e:
            console.print(f"[yellow]Aviso al consultar API ASUS para {model_code}: {e}[/yellow]")

        return drivers
