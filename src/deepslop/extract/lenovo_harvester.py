import os
import re
import asyncio
import xml.etree.ElementTree as ET
import httpx
from typing import Dict, List, Tuple
from rich.console import Console

from deepslop.models import DriverRef

console = Console()


class LenovoMetaHarvester:
    """Extrae metadatos y listados de drivers desde los archivos README de Lenovo."""

    def __init__(self, catalog_xml_path: str, output_dir: str):
        self.catalog_xml_path = catalog_xml_path
        self.output_dir = output_dir
        os.makedirs(self.output_dir, exist_ok=True)

    def get_readme_targets(self) -> List[Tuple[str, str]]:
        tree = ET.parse(self.catalog_xml_path)
        root = tree.getroot()

        targets = []
        for model in root.findall(".//Model"):
            name = model.attrib.get("name", "")
            for sccm in model.findall(".//SCCM"):
                url = sccm.text.strip() if sccm.text else ""
                if url.endswith(".exe"):
                    txt_url = url[:-4] + ".txt"
                    targets.append((name, txt_url))
        return targets

    async def harvest_readmes(self, limit: int = 50) -> Dict[str, List[DriverRef]]:
        targets = self.get_readme_targets()[:limit]
        results: Dict[str, List[DriverRef]] = {}

        limits = httpx.Limits(max_keepalive_connections=20, max_connections=20)
        async with httpx.AsyncClient(limits=limits, timeout=15.0, headers={"User-Agent": "Mozilla/5.0"}) as client:
            semaphore = asyncio.Semaphore(10)

            async def fetch_one(model_name: str, txt_url: str):
                filename = os.path.basename(txt_url)
                local_path = os.path.join(self.output_dir, filename)

                if os.path.exists(local_path):
                    with open(local_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                else:
                    async with semaphore:
                        try:
                            resp = await client.get(txt_url)
                            if resp.status_code == 200:
                                content = resp.text
                                with open(local_path, "w", encoding="utf-8") as f:
                                    f.write(content)
                            else:
                                return None
                        except Exception:
                            return None

                return self.parse_readme_text(content, model_name, txt_url)

            tasks = [fetch_one(name, url) for name, url in targets]
            completed = await asyncio.gather(*tasks)

            for item in completed:
                if item:
                    model_name, drivers = item
                    if model_name:
                        if model_name not in results:
                            results[model_name] = []
                        results[model_name].extend(drivers)

        return results

    def parse_readme_text(self, text: str, model_name: str, source_url: str):
        drivers: List[DriverRef] = []
        in_version_list = False

        for line in text.splitlines():
            line_s = line.strip()
            if "version list" in line_s.lower():
                in_version_list = True
                continue
            if in_version_list and (line_s.startswith("---") or line_s.startswith("===") or "limitations" in line_s.lower()):
                if drivers:
                    break

            if in_version_list and line_s:
                # Líneas del tipo: "Realtek Audio Driver   6.0.1.8258"
                parts = re.split(r"\s{2,}", line_s)
                if len(parts) >= 2:
                    name = parts[0].strip()
                    ver = parts[1].strip()

                    # Clasificar categoría
                    cat = "driver"
                    l_name = name.lower()
                    if "audio" in l_name:
                        cat = "audio"
                    elif "vga" in l_name or "video" in l_name or "graphics" in l_name:
                        cat = "display"
                    elif "wifi" in l_name or "wlan" in l_name or "lan" in l_name:
                        cat = "network"
                    elif "power" in l_name or "thermal" in l_name or "pm" in l_name or "acpi" in l_name:
                        cat = "power_thermal"
                    elif "touch" in l_name or "trackpoint" in l_name or "mouse" in l_name:
                        cat = "input"

                    drivers.append(
                        DriverRef(
                            category=cat,
                            name=name,
                            version=ver,
                            url=source_url,
                        )
                    )

        return (model_name, drivers)
