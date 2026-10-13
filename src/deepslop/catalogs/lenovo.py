import os
import xml.etree.ElementTree as ET
import httpx
from typing import List
from rich.console import Console

from deepslop.catalogs.base import BaseCatalog
from deepslop.models import LaptopModel, DriverPackRef

console = Console()

LENOVO_CDRT_URL = "https://download.lenovo.com/cdrt/td/catalogv2.xml"


class LenovoCatalog(BaseCatalog):
    @property
    def vendor_name(self) -> str:
        return "Lenovo"

    async def fetch_catalog(self, cache_dir: str) -> List[LaptopModel]:
        os.makedirs(cache_dir, exist_ok=True)
        xml_path = os.path.join(cache_dir, "lenovo_catalogv2.xml")

        if not os.path.exists(xml_path):
            console.print(f"[cyan]Descargando catálogo Lenovo CDRT de {LENOVO_CDRT_URL}...[/cyan]")
            async with httpx.AsyncClient(timeout=60.0) as client:
                resp = await client.get(LENOVO_CDRT_URL)
                resp.raise_for_status()
                with open(xml_path, "wb") as f:
                    f.write(resp.content)
            console.print(f"[green]Catálogo Lenovo guardado en {xml_path}[/green]")

        tree = ET.parse(xml_path)
        root = tree.getroot()

        models: List[LaptopModel] = []

        for model_elem in root.findall("Model"):
            name = model_elem.attrib.get("name", "").strip()
            if not name:
                continue

            # Extraer MTM Types (ej. 20UN, 20UQ, 21CB...)
            types = [t.text.strip() for t in model_elem.findall(".//Type") if t.text]
            
            # Detectar familia (ThinkPad, ThinkBook, Yoga, IdeaPad, etc.)
            family = "Other"
            lower_name = name.lower()
            if "thinkpad" in lower_name:
                family = "ThinkPad"
            elif "thinkbook" in lower_name:
                family = "ThinkBook"
            elif "yoga" in lower_name:
                family = "Yoga"
            elif "ideapad" in lower_name:
                family = "IdeaPad"
            elif "legion" in lower_name:
                family = "Legion"

            # Parsear paquetes SCCM
            driver_packs: List[DriverPackRef] = []
            for sccm in model_elem.findall(".//SCCM"):
                url = sccm.text.strip() if sccm.text else ""
                if not url:
                    continue
                os_ver = sccm.attrib.get("os", "win10")
                version = sccm.attrib.get("version", "*")
                release_date = sccm.attrib.get("date")
                crc = sccm.attrib.get("crc")
                md5 = sccm.attrib.get("md5")

                driver_packs.append(
                    DriverPackRef(
                        name=f"SCCM-{os_ver}-{version}",
                        os=f"{os_ver}-{version}",
                        url=url,
                        sha256=crc,
                        md5=md5,
                        release_date=release_date,
                    )
                )

            slug_id = f"lenovo-{name.lower().replace(' ', '-').replace('/', '-')}"
            
            laptop = LaptopModel(
                id=slug_id,
                vendor="Lenovo",
                family=family,
                model_name=name,
                system_id=",".join(types) if types else None,
                dmi_matches=types,
                driver_packs=driver_packs,
            )
            models.append(laptop)

        return models
