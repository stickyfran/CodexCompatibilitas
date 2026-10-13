import os
import json
from typing import List, Dict, Optional, Any
from rich.console import Console
from rich.table import Table

from deepslop.models import LaptopModel

console = Console()


class Registry:
    def __init__(self, db_root: str):
        self.db_root = db_root
        self.models_dir = os.path.join(db_root, "models")
        self.hwid_dir = os.path.join(db_root, "hwid")
        os.makedirs(self.models_dir, exist_ok=True)
        os.makedirs(self.hwid_dir, exist_ok=True)

    def save_models(self, models: List[LaptopModel]) -> int:
        count = 0
        for m in models:
            vendor_dir = os.path.join(self.models_dir, m.vendor.lower())
            os.makedirs(vendor_dir, exist_ok=True)
            path = os.path.join(vendor_dir, f"{m.id}.json")
            
            # Si ya existe, mergeamos información si es necesario
            with open(path, "w", encoding="utf-8") as f:
                f.write(m.model_dump_json(indent=2))
            count += 1
        return count

    def load_all_models(self) -> List[LaptopModel]:
        models = []
        for root, _, files in os.walk(self.models_dir):
            for file in files:
                if file.endswith(".json"):
                    full_path = os.path.join(root, file)
                    try:
                        with open(full_path, "r", encoding="utf-8") as f:
                            data = json.load(f)
                            models.append(LaptopModel(**data))
                    except Exception as e:
                        console.print(f"[red]Error cargando {full_path}: {e}[/red]")
        return models

    def get_summary(self) -> Dict[str, Any]:
        models = self.load_all_models()
        by_vendor: Dict[str, int] = {}
        by_family: Dict[str, int] = {}
        total_driver_packs = 0

        for m in models:
            by_vendor[m.vendor] = by_vendor.get(m.vendor, 0) + 1
            fam = f"{m.vendor} {m.family or 'General'}"
            by_family[fam] = by_family.get(fam, 0) + 1
            total_driver_packs += len(m.driver_packs)

        return {
            "total_models": len(models),
            "by_vendor": by_vendor,
            "by_family": by_family,
            "total_driver_packs": total_driver_packs,
        }

    def print_summary(self):
        summary = self.get_summary()
        table = Table(title="DeepSlopSuperLaptop — Base de Datos de Hardware")
        table.add_column("Fabricante", style="cyan")
        table.add_column("Modelos Indexados", justify="right", style="green")

        for vendor, count in summary["by_vendor"].items():
            table.add_row(vendor, str(count))

        table.add_row("[bold]TOTAL[/bold]", f"[bold]{summary['total_models']}[/bold]")
        console.print(table)
        console.print(f"[bold yellow]Total paquetes de drivers catalogados:[/bold yellow] [bold white]{summary['total_driver_packs']}[/bold white]")
