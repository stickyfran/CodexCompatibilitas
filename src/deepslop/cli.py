import asyncio
import os
from typing import Optional
import typer
from rich.console import Console

from deepslop.catalogs.lenovo import LenovoCatalog
from deepslop.catalogs.dell import DellCatalog
from deepslop.catalogs.hp import HPCatalog
from deepslop.catalogs.asus import AsusCatalog
from deepslop.index.registry import Registry

app = typer.Typer(
    name="deepslop",
    help="DeepSlopSuperLaptop — Base de datos masiva y herramientas de interoperabilidad OEM para Linux.",
    no_args_is_help=True,
)
catalog_app = typer.Typer(help="Comandos para sincronizar y explorar catálogos de fabricantes.")
app.add_typer(catalog_app, name="catalog")

console = Console()

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DATA_DIR = os.path.join(BASE_DIR, "data", "catalogs")
DB_DIR = os.path.join(BASE_DIR, "db")


@catalog_app.command("sync")
def catalog_sync(
    vendor: str = typer.Option("all", help="Fabricante a sincronizar: all, lenovo, dell, hp, asus"),
):
    """Descarga y parsea catálogos maestros oficiales de OEMs."""
    asyncio.run(_sync_catalogs(vendor))


async def _sync_catalogs(vendor: str):
    registry = Registry(DB_DIR)
    vendors = [vendor.lower()] if vendor.lower() != "all" else ["lenovo", "dell", "hp", "asus"]

    total_added = 0

    if "lenovo" in vendors:
        console.print("\n[bold blue]=== Sincronizando catálogo Lenovo CDRT ===[/bold blue]")
        lenovo = LenovoCatalog()
        models = await lenovo.fetch_catalog(DATA_DIR)
        saved = registry.save_models(models)
        console.print(f"[green]✓ Lenovo: {saved} modelos guardados en la base de datos.[/green]")
        total_added += saved

    if "dell" in vendors:
        console.print("\n[bold blue]=== Sincronizando catálogo Dell DriverPack ===[/bold blue]")
        dell = DellCatalog()
        models = await dell.fetch_catalog(DATA_DIR)
        saved = registry.save_models(models)
        console.print(f"[green]✓ Dell: {saved} modelos guardados en la base de datos.[/green]")
        total_added += saved

    if "hp" in vendors:
        console.print("\n[bold blue]=== Sincronizando catálogo HP SoftPaq ===[/bold blue]")
        hp = HPCatalog()
        models = await hp.fetch_catalog(DATA_DIR)
        saved = registry.save_models(models)
        console.print(f"[green]✓ HP: {saved} configuraciones de modelos guardadas en la base de datos.[/green]")
        total_added += saved

    if "asus" in vendors:
        console.print("\n[bold blue]=== Sincronizando catálogo ASUS (Sitemaps & Web API) ===[/bold blue]")
        asus = AsusCatalog()
        models = await asus.fetch_catalog(DATA_DIR)
        saved = registry.save_models(models)
        console.print(f"[green]✓ ASUS: {saved} modelos guardados en la base de datos.[/green]")
        total_added += saved

    console.print(f"\n[bold green]¡Sincronización completada! {total_added} modelos actualizados en {DB_DIR}[/bold green]")
    registry.print_summary()


@catalog_app.command("stats")
def catalog_stats():
    """Muestra estadísticas actuales de la base de datos DeepSlopSuperLaptop."""
    registry = Registry(DB_DIR)
    registry.print_summary()


@catalog_app.command("search")
def catalog_search(query: str = typer.Argument(..., help="Término a buscar (ej. 'x1 carbon', 's5506ma', 'xps 13')")):
    """Busca modelos en la base de datos por nombre o identificador."""
    registry = Registry(DB_DIR)
    models = registry.load_all_models()
    q = query.lower()

    matches = [
        m for m in models
        if q in m.model_name.lower() or (m.system_id and q in m.system_id.lower()) or any(q in d.lower() for d in m.dmi_matches)
    ]

    console.print(f"\n[bold]Resultados para '{query}' ({len(matches)} encontrados):[/bold]")
    for m in matches[:25]:
        packs_count = len(m.driver_packs)
        console.print(f"• [cyan]{m.vendor}[/cyan] [bold white]{m.model_name}[/bold white] (ID: [dim]{m.id}[/dim], SysID: [yellow]{m.system_id or 'N/A'}[/yellow]) - {packs_count} packs")

    if len(matches) > 25:
        console.print(f"[dim]...y {len(matches) - 25} resultados más.[/dim]")


@app.command("probe")
def probe_cmd():
    """Inspecciona el hardware de la máquina local y busca correspondencia en la base de datos."""
    from deepslop.probe.local_probe import probe_local_system

    console.print("\n[bold cyan]=== Inspeccionando hardware local ===[/bold cyan]")
    prof = probe_local_system()
    console.print(f"• [bold white]Fabricante:[/bold white] {prof.vendor}")
    console.print(f"• [bold white]Modelo / DMI:[/bold white] {prof.product_name} (Placa: {prof.board_name})")
    console.print(f"• [bold white]Versión BIOS:[/bold white] {prof.bios_version}")
    console.print(f"• [bold white]Codecs Audio:[/bold white] {', '.join(prof.audio_codecs) or 'Ninguno detectado'}")
    console.print(f"• [bold white]Dispositivos ACPI:[/bold white] {len(prof.acpi_devices)} detectados")

    registry = Registry(DB_DIR)
    models = registry.load_all_models()

    target_name = prof.product_name.lower()
    matches = [
        m for m in models
        if m.vendor.lower() in prof.vendor.lower() and (
            m.model_name.lower() in target_name
            or (m.system_id and m.system_id.lower() in target_name)
            or any(d.lower() in target_name for d in m.dmi_matches)
        )
    ]

    console.print(f"\n[bold green]Correspondencias en DeepSlopSuperLaptop:[/bold green]")
    if matches:
        for m in matches:
            console.print(f"✓ [cyan]{m.vendor}[/cyan] [bold white]{m.model_name}[/bold white] (ID: {m.id}) con {len(m.driver_packs)} paquetes de drivers oficiales.")
    else:
        console.print(f"[yellow]No se encontró coincidencia exacta directa para '{prof.product_name}'. Busque con `deepslop catalog search`.[/yellow]")


def main():
    app()


if __name__ == "__main__":
    main()
