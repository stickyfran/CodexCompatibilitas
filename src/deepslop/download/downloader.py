import os
import hashlib
import httpx
from typing import Optional
from rich.console import Console
from rich.progress import Progress, DownloadColumn, TransferSpeedColumn, TimeRemainingColumn

console = Console()


class Downloader:
    def __init__(self, cache_dir: str):
        self.cache_dir = cache_dir
        os.makedirs(cache_dir, exist_ok=True)

    def calculate_sha256(self, file_path: str) -> str:
        h = hashlib.sha256()
        with open(file_path, "rb") as f:
            while chunk := f.read(65536):
                h.update(chunk)
        return h.hexdigest()

    async def download_file(self, url: str, expected_hash: Optional[str] = None) -> Optional[str]:
        filename = os.path.basename(url.split("?")[0])
        target_path = os.path.join(self.cache_dir, filename)

        if os.path.exists(target_path):
            console.print(f"[dim]Usando copia en caché: {filename}[/dim]")
            return target_path

        console.print(f"[cyan]Descargando {filename} desde {url}...[/cyan]")
        try:
            async with httpx.AsyncClient(timeout=120.0, follow_redirects=True, headers={"User-Agent": "Mozilla/5.0"}) as client:
                async with client.stream("GET", url) as resp:
                    resp.raise_for_status()
                    total_bytes = int(resp.headers.get("content-length", 0))

                    with Progress(
                        *Progress.get_default_columns(),
                        DownloadColumn(),
                        TransferSpeedColumn(),
                        TimeRemainingColumn(),
                    ) as progress:
                        task = progress.add_task("Descargando...", total=total_bytes or None)
                        with open(target_path, "wb") as f:
                            async for chunk in resp.aiter_bytes(chunk_size=32768):
                                f.write(chunk)
                                progress.update(task, advance=len(chunk))

            if expected_hash:
                actual_sha = self.calculate_sha256(target_path)
                if expected_hash.lower() not in [actual_sha.lower()]:
                    console.print(f"[yellow]Aviso: hash de {filename} no coincide con el esperado.[/yellow]")

            return target_path
        except Exception as e:
            console.print(f"[red]Error descargando {url}: {e}[/red]")
            if os.path.exists(target_path):
                os.remove(target_path)
            return None
