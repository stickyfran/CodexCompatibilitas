import os
import asyncio
import xml.etree.ElementTree as ET
import httpx
from typing import Dict, List, Any
from rich.console import Console
from rich.progress import Progress, BarColumn, TextColumn, TimeRemainingColumn

from deepslop.models import LaptopModel, DriverRef

console = Console()


class DellManifestHarvester:
    """Extrae la lista completa de drivers, versiones y archivos para todas las laptops Dell."""

    BASE_URL = "https://downloads.dell.com"

    def __init__(self, catalog_xml_path: str, output_dir: str):
        self.catalog_xml_path = catalog_xml_path
        self.output_dir = output_dir
        os.makedirs(self.output_dir, exist_ok=True)

    def get_manifest_urls(self) -> List[Dict[str, str]]:
        tree = ET.parse(self.catalog_xml_path)
        root = tree.getroot()
        ns = {"d": "openmanage/cm/dm"}

        manifests = []
        for pkg in root.findall(".//d:DriverPackage", ns):
            meta = pkg.find(".//d:DriverPackMetadataInfo", ns)
            if meta is not None:
                p_elem = meta.find("d:path", ns)
                if p_elem is not None and p_elem.text:
                    rel_path = p_elem.text.strip()
                    release_id = pkg.attrib.get("releaseID", "")
                    url = f"{self.BASE_URL}/{rel_path}"
                    manifests.append({"url": url, "rel_path": rel_path, "release_id": release_id})
        return manifests

    async def harvest_manifests(self, limit: int = 50) -> Dict[str, List[DriverRef]]:
        manifest_items = self.get_manifest_urls()[:limit]
        results: Dict[str, List[DriverRef]] = {}

        limits = httpx.Limits(max_keepalive_connections=20, max_connections=20)
        async with httpx.AsyncClient(limits=limits, timeout=15.0, headers={"User-Agent": "Mozilla/5.0"}) as client:
            semaphore = asyncio.Semaphore(10)

            async def fetch_one(item):
                filename = os.path.basename(item["rel_path"])
                local_path = os.path.join(self.output_dir, filename)

                if os.path.exists(local_path):
                    with open(local_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                else:
                    async with semaphore:
                        try:
                            resp = await client.get(item["url"])
                            if resp.status_code == 200:
                                content = resp.text
                                with open(local_path, "w", encoding="utf-8") as f:
                                    f.write(content)
                            else:
                                return None
                        except Exception:
                            return None

                # Parsear contenido del XML
                return self.parse_manifest_xml(content, filename)

            tasks = [fetch_one(item) for item in manifest_items]
            completed = await asyncio.gather(*tasks)

            for c in completed:
                if c:
                    sys_id, drivers = c
                    if sys_id:
                        results[sys_id] = drivers

        return results

    def parse_manifest_xml(self, xml_content: str, source_filename: str):
        try:
            root = ET.fromstring(xml_content)
        except Exception:
            return None

        # SystemID
        sys_elem = root.find(".//System")
        sys_id = sys_elem.attrib.get("SystemID", "").strip() if sys_elem is not None else ""

        drivers: List[DriverRef] = []
        for release in root.findall(".//Release"):
            category = release.attrib.get("Category", "other").lower()
            desc = release.attrib.get("DeviceDescription", "")
            vendor_ver = release.attrib.get("VendorVersion", "")
            dell_ver = release.attrib.get("DellVersion", "")
            release_id = release.attrib.get("ReleaseID", "")

            # Extraer archivos del paquete
            inf_files = []
            bin_files = []
            for pkg in release.findall(".//Package"):
                dest = pkg.attrib.get("DestPath", "")
                if dest.lower().endswith(".inf"):
                    inf_files.append(os.path.basename(dest))
                elif any(dest.lower().endswith(ext) for ext in [".wmfw", ".bin", ".icm"]):
                    bin_files.append(os.path.basename(dest))

            driver = DriverRef(
                category=category,
                name=desc or release_id,
                version=vendor_ver or dell_ver,
                url=f"dell-pack://{source_filename}/{release_id}",
                hardware_ids=inf_files + bin_files,
            )
            drivers.append(driver)

        return (sys_id, drivers)
