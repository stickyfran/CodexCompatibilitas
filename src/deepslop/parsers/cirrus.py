import os
import shutil
from typing import List, Dict, Optional
from pydantic import BaseModel


class CirrusFirmwareAsset(BaseModel):
    wmfw_filename: str
    bin_filename: str
    subsystem_id: str
    source_path: str


class CirrusExtractor:
    """Detecta y extrae blobs de firmware para amplificadores Cirrus Logic CS35L41/CS35L56."""

    @staticmethod
    def scan_directory(extracted_dir: str) -> List[CirrusFirmwareAsset]:
        assets: List[CirrusFirmwareAsset] = []

        wmfw_files = []
        bin_files = []

        for root, _, files in os.walk(extracted_dir):
            for file in files:
                lower = file.lower()
                full_path = os.path.join(root, file)
                if lower.endswith(".wmfw") and "cs35l" in lower:
                    wmfw_files.append((file, full_path))
                elif lower.endswith(".bin") and ("cs35l" in lower or "spk-prot" in lower):
                    bin_files.append((file, full_path))

        # Asociar por subsystem ID
        for bin_name, bin_path in bin_files:
            # Buscar subsystem ID en el nombre (ej. cs35l41-dsp1-spk-prot-10431433.bin)
            parts = bin_name.replace(".bin", "").split("-")
            subsys = parts[-1] if len(parts) > 1 else "unknown"

            # Buscar wmfw correspondiente
            wmfw_name = "cs35l41-dsp1-spk-prot.wmfw"
            for w_name, _ in wmfw_files:
                if "spk-prot" in w_name:
                    wmfw_name = w_name
                    break

            assets.append(
                CirrusFirmwareAsset(
                    wmfw_filename=wmfw_name,
                    bin_filename=bin_name,
                    subsystem_id=subsys,
                    source_path=os.path.dirname(bin_path),
                )
            )

        return assets

    @staticmethod
    def install_to_system(asset: CirrusFirmwareAsset, dest_dir: str = "/lib/firmware/cirrus") -> str:
        """Genera comandos de instalación para el firmware del kernel."""
        commands = [
            f"sudo mkdir -p {dest_dir}",
            f"sudo cp {os.path.join(asset.source_path, asset.wmfw_filename)} {dest_dir}/",
            f"sudo cp {os.path.join(asset.source_path, asset.bin_filename)} {dest_dir}/",
        ]
        return "\n".join(commands)
