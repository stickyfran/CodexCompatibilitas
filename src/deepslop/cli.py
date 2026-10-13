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


@catalog_app.command("harvest")
def catalog_harvest(
    vendor: str = typer.Option("all", help="Fabricante a extraer metadatos: all, dell, hp, lenovo"),
    limit: int = typer.Option(50, help="Límite de manifiestos/CVAs a extraer"),
):
    """Extrae la lista granular de drivers individuales (.inf, versiones, audio, chips) desde los manifiestos oficiales."""
    asyncio.run(_harvest_drivers(vendor, limit))


async def _harvest_drivers(vendor: str, limit: int):
    from deepslop.extract.dell_harvester import DellManifestHarvester
    from deepslop.extract.hp_harvester import HPMetaHarvester
    from deepslop.extract.lenovo_harvester import LenovoMetaHarvester

    registry = Registry(DB_DIR)
    models = {m.id: m for m in registry.load_all_models()}
    vendors = [vendor.lower()] if vendor.lower() != "all" else ["dell", "hp", "lenovo"]

    total_drivers_harvested = 0
    updated_models: Dict[str, LaptopModel] = {}

    if "dell" in vendors:
        console.print(f"\n[bold cyan]=== Extrayendo manifiestos de drivers de Dell (límite {limit}) ===[/bold cyan]")
        dh = DellManifestHarvester(
            catalog_xml_path=os.path.join(DATA_DIR, "DriverPackCatalog.xml"),
            output_dir=os.path.join(BASE_DIR, "data", "manifests", "dell"),
        )
        dell_results = await dh.harvest_manifests(limit=limit)
        console.print(f"[green]✓ Extraídos {len(dell_results)} manifiestos de sistemas Dell.[/green]")

        for sys_id, drivers in dell_results.items():
            for m in models.values():
                if m.vendor.lower() == "dell" and (m.system_id == sys_id or any(sys_id.lower() in d.lower() for d in m.dmi_matches)):
                    m.individual_drivers.extend(drivers)
                    total_drivers_harvested += len(drivers)
                    updated_models[m.id] = m

    if "hp" in vendors:
        console.print(f"\n[bold cyan]=== Extrayendo metadatos CVA de HP (límite {limit}) ===[/bold cyan]")
        hh = HPMetaHarvester(
            catalog_xml_path=os.path.join(DATA_DIR, "HPClientDriverPackCatalog.xml"),
            output_dir=os.path.join(BASE_DIR, "data", "manifests", "hp"),
        )
        hp_results = await hh.harvest_cvas(limit=limit)
        console.print(f"[green]✓ Extraídos metadatos de {len(hp_results)} sistemas HP.[/green]")

        for sys_id, drivers in hp_results.items():
            for m in models.values():
                if m.vendor.lower() == "hp" and (m.system_id == sys_id or any(sys_id.lower() in d.lower() for d in m.dmi_matches)):
                    m.individual_drivers.extend(drivers)
                    total_drivers_harvested += len(drivers)
                    updated_models[m.id] = m

    if "lenovo" in vendors:
        console.print(f"\n[bold cyan]=== Extrayendo READMEs de drivers de Lenovo (límite {limit}) ===[/bold cyan]")
        lh = LenovoMetaHarvester(
            catalog_xml_path=os.path.join(DATA_DIR, "lenovo_catalogv2.xml"),
            output_dir=os.path.join(BASE_DIR, "data", "manifests", "lenovo"),
        )
        lenovo_results = await lh.harvest_readmes(limit=limit)
        console.print(f"[green]✓ Extraídos listados de drivers de {len(lenovo_results)} modelos Lenovo.[/green]")

        for model_name, drivers in lenovo_results.items():
            for m in models.values():
                if m.vendor.lower() == "lenovo" and m.model_name.lower() in model_name.lower():
                    m.individual_drivers.extend(drivers)
                    total_drivers_harvested += len(drivers)
                    updated_models[m.id] = m

    if updated_models:
        registry.save_models(list(updated_models.values()))
        console.print(f"\n[bold green]¡Extracción masiva completada! {total_drivers_harvested} drivers individuales mapeados en {len(updated_models)} modelos.[/bold green]")
    else:
        console.print("[yellow]No se encontraron modelos locales para vincular los manifiestos.[/yellow]")


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
    console.print(f"• [bold white]Subsystem PCI clave:[/bold white] {len(prof.pci_subsystems)} dispositivos mapeados")
    console.print(f"• [bold white]Dispositivos ACPI:[/bold white] {len(prof.acpi_devices)} detectados")

    console.print(f"\n[bold yellow]=== Diagnóstico Térmico y de Rendimiento ===[/bold yellow]")
    th = prof.thermal
    if th.platform_profiles:
        console.print(f"• [bold white]Perfiles Térmicos (ACPI):[/bold white] {', '.join(th.platform_profiles)} (Activo: [green]{th.current_profile or 'N/A'}[/green])")
    if th.wmi_thermal_interface:
        console.print(f"• [bold white]Controlador WMI OEM:[/bold white] [cyan]{th.wmi_thermal_interface}[/cyan]")
    if th.cooling_devices:
        console.print(f"• [bold white]Dispositivos de Enfriamiento (Fans):[/bold white] {', '.join(th.cooling_devices)}")
    if th.acpi_thermal_hids:
        console.print(f"• [bold white]HIDs Sensores / DPTF:[/bold white] {', '.join(th.acpi_thermal_hids)}")
    if th.thermal_zones:
        console.print(f"• [bold white]Zonas Térmicas:[/bold white] {', '.join(th.thermal_zones[:4])}")

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
            if m.components:
                console.print(f"  [bold]Componentes configurados:[/bold]")
                for comp, status in m.components.items():
                    console.print(f"    • {comp}: [green]{status.status}[/green] ({status.fix_type or 'nativo'})")
    else:
        console.print(f"[yellow]No se encontró coincidencia exacta directa para '{prof.product_name}'. Busque con `deepslop catalog search`.[/yellow]")


@app.command("process")
def process_cmd(
    model_id: str = typer.Argument(..., help="ID del modelo a procesar (ej. asus-vivobook-s-15-oled-s5506ma)"),
):
    """Descarga, extrae y analiza los paquetes de drivers de un modelo para generar fixes nativos."""
    asyncio.run(_process_model(model_id))


async def _process_model(model_id: str):
    from deepslop.download.downloader import Downloader
    from deepslop.extract.unpacker import Unpacker
    from deepslop.parsers.cirrus import CirrusExtractor
    from deepslop.parsers.dolby import parse_dolby_xml, generate_pipewire_filter_chain
    from deepslop.parsers.icm import ICMProfileInfo

    registry = Registry(DB_DIR)
    models = registry.load_all_models()
    matched = next((m for m in models if m.id == model_id), None)

    if not matched:
        console.print(f"[red]Modelo {model_id} no encontrado en la base de datos.[/red]")
        return

    console.print(f"\n[bold cyan]Procesando {matched.vendor} {matched.model_name}...[/bold cyan]")
    if not matched.driver_packs:
        console.print(f"[yellow]No hay paquetes de drivers registrados para {model_id}.[/yellow]")
        return

    downloader = Downloader(os.path.join(BASE_DIR, "data", "cache"))
    extract_base = os.path.join(BASE_DIR, "data", "extracted", model_id)
    fixes_base = os.path.join(BASE_DIR, "fixes", model_id)
    os.makedirs(fixes_base, exist_ok=True)

    for pack in matched.driver_packs:
        console.print(f"\n[bold]Analizando paquete: {pack.name}[/bold]")
        downloaded = await downloader.download_file(pack.url, pack.sha256 or pack.md5)
        if not downloaded:
            continue

        pack_extract_dir = os.path.join(extract_base, pack.name)
        unpacked = Unpacker.unpack(downloaded, pack_extract_dir)
        if not unpacked:
            console.print(f"[yellow]No se pudo desempaquetar {pack.name} o el contenido está vacío.[/yellow]")
            continue

        console.print(f"[green]✓ Desempaquetado exitoso en {pack_extract_dir}[/green]")

        # 1. Escanear amplificadores Cirrus Logic
        cirrus_assets = CirrusExtractor.scan_directory(pack_extract_dir)
        if cirrus_assets:
            console.print(f"[bold green]✓ Detectados {len(cirrus_assets)} firmwares de amplificador Cirrus Logic CS35L41![/bold green]")
            for ca in cirrus_assets:
                install_script = os.path.join(fixes_base, "install_cirrus_firmware.sh")
                with open(install_script, "w") as f:
                    f.write("#!/bin/bash\n" + CirrusExtractor.install_to_system(ca))
                os.chmod(install_script, 0o755)
                console.print(f"  → Script generado: {install_script}")
                matched.components["audio_amp"] = {
                    "status": "fixed",
                    "fix_type": "cirrus_kernel_firmware",
                    "fix_path": install_script,
                    "details": {"subsystem": ca.subsystem_id, "bin": ca.bin_filename}
                }

        # 2. Escanear perfiles de color ICM
        icm_count = 0
        for root, _, files in os.walk(pack_extract_dir):
            for file in files:
                if file.lower().endswith(".icm") or file.lower().endswith(".icc"):
                    icm_path = os.path.join(root, file)
                    info = ICMProfileInfo(icm_path)
                    dest_icm = os.path.join(fixes_base, file)
                    import shutil
                    shutil.copy2(icm_path, dest_icm)
                    icm_count += 1
                    console.print(f"[bold green]✓ Perfil de color detectado: {file} ({info.description or 'Monitor'})[/bold green]")
        if icm_count > 0:
            matched.components["display_color"] = {
                "status": "fixed",
                "fix_type": "color_icc_profile",
                "fix_path": fixes_base,
            }

    # Guardar modelo actualizado en DB
    registry.save_models([matched])
    console.print(f"\n[bold green]¡Procesamiento finalizado para {model_id}! Registro actualizado en DB.[/bold green]")


def main():
    app()


if __name__ == "__main__":
    main()

