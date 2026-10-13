import os
import subprocess
import shutil
from typing import Optional
from rich.console import Console

console = Console()


class Unpacker:
    """Extractor universal para instaladores y paquetes de drivers OEM."""

    @staticmethod
    def unpack(archive_path: str, output_dir: str) -> bool:
        os.makedirs(output_dir, exist_ok=True)
        lower_path = archive_path.lower()

        # 1. Intentar con 7z primero (soporta CAB, ZIP, RAR, NSIS, Inno básicos, TAR)
        cmd_7z = ["7z", "x", "-y", f"-o{output_dir}", archive_path]
        try:
            res = subprocess.run(cmd_7z, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if res.returncode == 0 and os.listdir(output_dir):
                return True
        except Exception:
            pass

        # 2. Si es .cab o falló 7z, intentar con cabextract
        if lower_path.endswith(".cab"):
            cmd_cab = ["cabextract", "-d", output_dir, archive_path]
            try:
                res = subprocess.run(cmd_cab, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                if res.returncode == 0 and os.listdir(output_dir):
                    return True
            except Exception:
                pass

        # 3. Intentar con innoextract (para instaladores InnoSetup comunes en Dell, Asus y Realtek)
        cmd_inno = ["innoextract", "-d", output_dir, archive_path]
        try:
            res = subprocess.run(cmd_inno, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if res.returncode == 0 and os.listdir(output_dir):
                return True
        except Exception:
            pass

        # 4. Búsqueda de offset de 7z o PK-ZIP embebido en archivo ejecutable PE
        try:
            with open(archive_path, "rb") as f:
                data = f.read()

            # Firma 7z: 37 7A BC AF 27 1C
            magic_7z = b"7z\xbc\xaf'\x1c"
            offset_7z = data.find(magic_7z)
            if offset_7z != -1:
                temp_7z = os.path.join(output_dir, "embedded.7z")
                with open(temp_7z, "wb") as f_out:
                    f_out.write(data[offset_7z:])
                cmd = ["7z", "x", "-y", f"-o{output_dir}", temp_7z]
                res = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                os.remove(temp_7z)
                if res.returncode == 0 and os.listdir(output_dir):
                    return True
        except Exception as e:
            console.print(f"[yellow]Error escaneando offset embebido en {archive_path}: {e}[/yellow]")

        return False
