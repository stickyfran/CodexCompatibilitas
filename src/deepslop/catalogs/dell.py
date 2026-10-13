import os
import xml.etree.ElementTree as ET
from typing import List, Dict
from rich.console import Console

from deepslop.catalogs.base import BaseCatalog
from deepslop.models import LaptopModel, DriverPackRef

console = Console()

DELL_CATALOG_URL = "https://downloads.dell.com/catalog/DriverPackCatalog.cab"


class DellCatalog(BaseCatalog):
    @property
    def vendor_name(self) -> str:
        return "Dell"

    async def fetch_catalog(self, cache_dir: str) -> List[LaptopModel]:
        os.makedirs(cache_dir, exist_ok=True)
        xml_path = os.path.join(cache_dir, "DriverPackCatalog.xml")

        if not os.path.exists(xml_path):
            console.print(f"[cyan]Catálogo Dell no encontrado en caché local. Descomprima {DELL_CATALOG_URL}...[/cyan]")
            return []

        tree = ET.parse(xml_path)
        root = tree.getroot()
        ns = {"d": "openmanage/cm/dm"}

        base_location = root.attrib.get("baseLocation", "downloads.dell.com")

        # Mapeo: system_id -> LaptopModel
        models_by_sysid: Dict[str, LaptopModel] = {}

        for pkg in root.findall(".//d:DriverPackage", ns):
            path = pkg.attrib.get("path", "")
            if not path:
                continue

            url = f"https://{base_location}/{path}"
            size = int(pkg.attrib.get("size", 0)) if pkg.attrib.get("size") else None
            md5 = pkg.attrib.get("hashMD5")
            release_id = pkg.attrib.get("releaseID", "")
            date_time = pkg.attrib.get("dateTime", "")

            # Extraer OS
            os_elems = pkg.findall(".//d:OperatingSystem", ns)
            os_names = [o.attrib.get("osCode", "") for o in os_elems if o.attrib.get("osCode")]
            os_str = "/".join(os_names) if os_names else "win"

            # Buscar hashes criptográficos adicionales
            sha256 = None
            for h in pkg.findall(".//d:Hash", ns):
                if h.attrib.get("algorithm") == "SHA256" and h.text:
                    sha256 = h.text.strip()
                    break

            pack_ref = DriverPackRef(
                name=f"DellPack-{release_id}",
                os=os_str,
                url=url,
                size_bytes=size,
                md5=md5,
                sha256=sha256,
                release_date=date_time,
            )

            # Extraer modelos soportados
            for brand_elem in pkg.findall(".//d:Brand", ns):
                brand_display = brand_elem.find("d:Display", ns)
                family = brand_display.text.strip() if brand_display is not None and brand_display.text else "Dell"

                for model_elem in brand_elem.findall("d:Model", ns):
                    sys_id = model_elem.attrib.get("systemID", "").strip()
                    name = model_elem.attrib.get("name", "").strip()
                    if not sys_id or not name:
                        continue

                    # Solo nos interesan familias de laptops/móviles/desktops relevantes
                    # (Latitude, XPS, Inspiron, Precision, Alienware, Vostro)
                    if sys_id not in models_by_sysid:
                        slug_id = f"dell-{name.lower().replace(' ', '-').replace('/', '-')}-{sys_id.lower()}"
                        models_by_sysid[sys_id] = LaptopModel(
                            id=slug_id,
                            vendor="Dell",
                            family=family,
                            model_name=name,
                            system_id=sys_id,
                            dmi_matches=[name, sys_id],
                            driver_packs=[pack_ref],
                        )
                    else:
                        # Agregar el pack si no existe ya
                        if not any(p.url == pack_ref.url for p in models_by_sysid[sys_id].driver_packs):
                            models_by_sysid[sys_id].driver_packs.append(pack_ref)

        return list(models_by_sysid.values())
