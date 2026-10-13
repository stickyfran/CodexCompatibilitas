import os
import re
import xml.etree.ElementTree as ET
import httpx
from typing import List, Set
from rich.console import Console

from deepslop.catalogs.base import BaseCatalog
from deepslop.models import LaptopModel

console = Console()

ASUS_SITEMAP_INDEX = "https://www.asus.com/sitemap.xml"


class AsusCatalog(BaseCatalog):
    @property
    def vendor_name(self) -> str:
        return "ASUS"

    async def fetch_catalog(self, cache_dir: str) -> List[LaptopModel]:
        os.makedirs(cache_dir, exist_ok=True)
        models_cache_file = os.path.join(cache_dir, "asus_discovered_models.txt")

        discovered_slugs: Set[str] = set()

        if os.path.exists(models_cache_file):
            console.print(f"[cyan]Cargando modelos ASUS desde {models_cache_file}...[/cyan]")
            with open(models_cache_file, "r") as f:
                for line in f:
                    if line.strip():
                        discovered_slugs.add(line.strip())
        else:
            console.print("[cyan]Parseando sitemaps de ASUS para descubrir modelos de laptops...[/cyan]")
            # Modelos populares base asegurados (Zenbook, Vivobook, ROG, TUF)
            curated_base = [
                "vivobook-s-15-oled-s5506ma", "vivobook-s-14-oled-s5406ma", "vivobook-pro-16x-oled-k6604",
                "vivobook-s16-s3607q", "zenbook-14x-oled-ux3404", "zenbook-14-oled-ux3402",
                "zenbook-duo-oled-ux8406", "zenbook-pro-14-oled-ux6404", "rog-zephyrus-g14-ga403",
                "rog-zephyrus-g16-gu605", "rog-strix-scar-16-g634", "rog-strix-scar-18-g834",
                "rog-flow-x13-gv302", "rog-flow-z13-gz301", "asus-tuf-gaming-a15-fa507",
                "asus-tuf-gaming-f15-fx507", "asus-tuf-gaming-a16-fa607", "asus-tuf-gaming-f16-fx607",
                "expertbook-b5-b5402c", "expertbook-b9-b9400", "proart-p16-h7606"
            ]
            for m in curated_base:
                discovered_slugs.add(m)

            for sitemap_file in ["asus_us1.xml", "asus_us2.xml"]:
                full_path = os.path.join(cache_dir, sitemap_file)
                if os.path.exists(full_path):
                    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                        text = f.read()
                        urls = re.findall(r"https://www.asus.com/us/laptops/([^\"<]+)", text)
                        for u in urls:
                            parts = u.strip("/").split("/")
                            if len(parts) >= 2:
                                last_part = parts[-1]
                                if last_part not in ["techspec", "review", "where-to-buy", "features"]:
                                    discovered_slugs.add(last_part)

            with open(models_cache_file, "w") as f:
                for slug in sorted(discovered_slugs):
                    f.write(f"{slug}\n")
            console.print(f"[green]Descubiertos {len(discovered_slugs)} modelos/líneas ASUS.[/green]")

        models: List[LaptopModel] = []
        for slug in sorted(discovered_slugs):
            # Intentar extraer el código de modelo final (ej: ux3404, s5506ma, k6604)
            # Generalmente los modelos ASUS terminan con el código de hardware
            tokens = slug.split("-")
            candidate_model = tokens[-1].upper()

            # Categorizar familia
            family = "ASUS"
            if "zenbook" in slug:
                family = "Zenbook"
            elif "vivobook" in slug:
                family = "Vivobook"
            elif "rog" in slug or "strix" in slug or "zephyrus" in slug:
                family = "ROG"
            elif "tuf" in slug:
                family = "TUF Gaming"
            elif "expertbook" in slug:
                family = "ExpertBook"
            elif "proart" in slug:
                family = "ProArt"

            laptop = LaptopModel(
                id=f"asus-{slug}",
                vendor="ASUS",
                family=family,
                model_name=slug.replace("-", " ").title(),
                system_id=candidate_model if len(candidate_model) >= 4 else None,
                dmi_matches=[candidate_model] if len(candidate_model) >= 4 else [],
            )
            models.append(laptop)

        return models
