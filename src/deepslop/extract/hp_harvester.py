import os
import re
import asyncio
import xml.etree.ElementTree as ET
import httpx
from typing import Dict, List, Tuple, Optional
from rich.console import Console

from deepslop.models import DriverRef

console = Console()


class HPMetaHarvester:
    """Extrae metadatos y Hardware IDs de los archivos CVA de HP vinculados a los productos del catálogo."""

    def __init__(self, catalog_xml_path: str, output_dir: str):
        self.catalog_xml_path = catalog_xml_path
        self.output_dir = output_dir
        os.makedirs(self.output_dir, exist_ok=True)
        self.sp_to_system_ids: Dict[str, List[str]] = {}
        self._load_product_mapping()

    def _load_product_mapping(self):
        tree = ET.parse(self.catalog_xml_path)
        root = tree.getroot()
        for p in root.findall(".//ProductOSDriverPack"):
            sp = p.findtext("SoftPaqId", "").strip().lower()
            sys_id = p.findtext("SystemId", "").strip()
            if sp and sys_id:
                if sp not in self.sp_to_system_ids:
                    self.sp_to_system_ids[sp] = []
                for s in sys_id.split(","):
                    clean_s = s.strip().lower()
                    if clean_s and clean_s not in self.sp_to_system_ids[sp]:
                        self.sp_to_system_ids[sp].append(clean_s)

    def get_cva_targets(self) -> List[Tuple[str, str]]:
        tree = ET.parse(self.catalog_xml_path)
        root = tree.getroot()

        targets = []
        for sp in root.findall(".//SoftPaq"):
            sp_id = sp.findtext("Id", "").strip()
            url = sp.findtext("Url", "").strip()
            if url.endswith(".exe"):
                cva_url = url[:-4] + ".cva"
                targets.append((sp_id, cva_url))
        return targets

    async def harvest_cvas(self, limit: int = 50) -> Dict[str, List[DriverRef]]:
        targets = self.get_cva_targets()[:limit]
        results: Dict[str, List[DriverRef]] = {}

        limits = httpx.Limits(max_keepalive_connections=20, max_connections=20)
        async with httpx.AsyncClient(limits=limits, timeout=15.0, headers={"User-Agent": "Mozilla/5.0"}) as client:
            semaphore = asyncio.Semaphore(10)

            async def fetch_one(sp_id: str, cva_url: str):
                filename = f"{sp_id}.cva"
                local_path = os.path.join(self.output_dir, filename)

                if os.path.exists(local_path):
                    with open(local_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                else:
                    async with semaphore:
                        try:
                            resp = await client.get(cva_url)
                            if resp.status_code == 200:
                                content = resp.text
                                with open(local_path, "w", encoding="utf-8") as f:
                                    f.write(content)
                            else:
                                return None
                        except Exception:
                            return None

                return self.parse_cva_text(content, sp_id, cva_url)

            tasks = [fetch_one(sp_id, url) for sp_id, url in targets]
            completed = await asyncio.gather(*tasks)

            for item in completed:
                if item:
                    sp_id, driver, system_ids = item
                    # Unir los system_ids encontrados en el texto del CVA con los del catálogo XML
                    all_sys_ids = set(system_ids + self.sp_to_system_ids.get(sp_id.lower(), []))
                    for sys_id in all_sys_ids:
                        clean_id = sys_id.strip().lower()
                        if clean_id not in results:
                            results[clean_id] = []
                        results[clean_id].append(driver)

        return results

    def parse_cva_text(self, text: str, sp_id: str, source_url: str):
        title = ""
        category = "driver"
        version = ""
        system_ids = []
        hwids = []

        lines = text.splitlines()
        current_section = ""

        for line in lines:
            line_s = line.strip()
            if line_s.startswith("[") and line_s.endswith("]"):
                current_section = line_s[1:-1].lower()
                continue

            if "=" in line_s:
                k, v = line_s.split("=", 1)
                k = k.strip().lower()
                v = v.strip()

                if current_section == "software title" and k == "us":
                    title = v
                elif current_section == "general" and k == "category":
                    category = v.lower()
                elif current_section == "general" and k == "version":
                    version = v
                elif current_section == "system information":
                    if "systemid" in k:
                        system_ids.extend([s.strip().lower() for s in v.split(",") if s.strip()])
                elif "device" in current_section or "hardware" in current_section:
                    hwids.append(v)

        driver = DriverRef(
            category=category,
            name=title or sp_id,
            version=version,
            url=source_url,
            hardware_ids=hwids,
        )
        return (sp_id, driver, system_ids)
