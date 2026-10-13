import os
import xml.etree.ElementTree as ET
from typing import List, Dict
from rich.console import Console

from deepslop.catalogs.base import BaseCatalog
from deepslop.models import LaptopModel, DriverPackRef

console = Console()

HP_CATALOG_URL = "https://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab"


class HPCatalog(BaseCatalog):
    @property
    def vendor_name(self) -> str:
        return "HP"

    async def fetch_catalog(self, cache_dir: str) -> List[LaptopModel]:
        os.makedirs(cache_dir, exist_ok=True)
        xml_path = os.path.join(cache_dir, "HPClientDriverPackCatalog.xml")

        if not os.path.exists(xml_path):
            console.print(f"[cyan]Catálogo HP no encontrado en {xml_path}[/cyan]")
            return []

        tree = ET.parse(xml_path)
        root = tree.getroot()

        # 1. Mapear SoftPaqs por Id (ej: sp80493)
        softpaqs: Dict[str, DriverPackRef] = {}
        for sp in root.findall(".//SoftPaq"):
            sp_id = sp.findtext("Id", "").strip()
            if not sp_id:
                continue

            name = sp.findtext("Name", "").strip()
            url = sp.findtext("Url", "").strip()
            version = sp.findtext("Version", "").strip()
            release_date = sp.findtext("DateReleased", "").strip()
            size_str = sp.findtext("Size", "0").strip()
            md5 = sp.findtext("MD5", "").strip()

            size = int(size_str) if size_str.isdigit() else None

            softpaqs[sp_id.lower()] = DriverPackRef(
                name=f"{sp_id}-{name}",
                os="Windows",
                url=url,
                version=version,
                size_bytes=size,
                md5=md5,
                release_date=release_date,
            )

        # 2. Mapear Productos
        models_by_sysid: Dict[str, LaptopModel] = {}

        for prod in root.findall(".//ProductOSDriverPack"):
            sys_id = prod.findtext("SystemId", "").strip()
            name = prod.findtext("SystemName", "").strip()
            sp_id = prod.findtext("SoftPaqId", "").strip().lower()
            os_name = prod.findtext("OSName", "").strip()

            if not sys_id or not name:
                continue

            # Detectar familia (EliteBook, ProBook, Spectre, Envy, ZBook, OMEN, Pavilion...)
            family = "HP"
            lower_name = name.lower()
            for fam in ["elitebook", "probook", "spectre", "envy", "zbook", "omen", "victus", "pavilion", "dragonfly"]:
                if fam in lower_name:
                    family = fam.capitalize()
                    break

            pack = softpaqs.get(sp_id)

            if sys_id not in models_by_sysid:
                slug_id = f"hp-{name.lower().replace(' ', '-').replace('/', '-')}-{sys_id.split(',')[0].lower()}"
                
                # Soportar múltiples IDs separados por coma (ej: 81c3,8396)
                sys_ids_list = [s.strip() for s in sys_id.split(",") if s.strip()]
                
                models_by_sysid[sys_id] = LaptopModel(
                    id=slug_id,
                    vendor="HP",
                    family=family,
                    model_name=name,
                    system_id=sys_id,
                    dmi_matches=sys_ids_list + [name],
                    driver_packs=[pack] if pack else [],
                )
            else:
                if pack and not any(p.url == pack.url for p in models_by_sysid[sys_id].driver_packs):
                    models_by_sysid[sys_id].driver_packs.append(pack)

        return list(models_by_sysid.values())
