# Guía de Construcción y Empaquetado (BUILD.md)

Esta guía documenta los requisitos de entorno, compilación de módulos del kernel, ejecución de la suite de herramientas y empaquetado del proyecto **CodexCompatibilitas**.

---

## 1. Requisitos del Entorno

### 1.1. Dependencias del Entorno Python (Herramientas y CLI)
El motor de generación e inspección del catálogo está construido en Python modular utilizando [`uv`](https://docs.astral.sh/uv/) para la gestión de dependencias y entornos virtuales:

- **Python:** Versión `>= 3.11`
- **Gestor de paquetes:** `uv` (recomendado) o `pip`

Instalación de dependencias del entorno de trabajo:
```bash
# Sincronizar entorno virtual lockeado con uv
uv sync
```

### 1.2. Herramientas de Extracción y Desensamblado OEM
Para extraer drivers empaquetados en instaladores de Windows (.exe, .msi, .cab) directamente en Linux:
- `p7zip` (`7z`)
- `cabextract`
- `innoextract`
- `msitools` (`msiextract`)

En sistemas basados en Arch / CachyOS:
```bash
sudo pacman -S --needed p7zip cabextract innoextract msitools
```

En sistemas basados en Debian / Ubuntu:
```bash
sudo apt-get install p7zip-full cabextract innoextract msitools
```

### 1.3. Requisitos para Módulos de Kernel (Out-of-Tree C Drivers)
Para construir los módulos del kernel de Linux (como `hid-asus-lamparray.ko` o controladores de retroiluminación/hotkeys):
- **Linux Headers:** Cabeceras correspondientes al kernel en ejecución (`linux-headers`, `linux-cachyos-headers` o `linux-cachyos-bore-lto-headers`).
- **Cadena de herramientas C:** `gcc`, `make` o `clang`.
- **Enlazador LLVM (`lld`):** **Crucial.** En distribuciones optimizadas (como CachyOS) cuyos kernels se construyen con Clang y `CONFIG_LTO_CLANG_THIN=y`, `make` invoca `/usr/bin/ld.lld`. Si falta `lld`, la compilación fallará con `Error 127: ld.lld: command not found`.

Instalar en CachyOS / Arch:
```bash
sudo pacman -S --needed base-devel clang lld linux-headers
```

---

## 2. Construcción y Ejecución de la Herramienta CLI

### 2.1. Comandos de la CLI `deepslop`
El binario virtual de la suite se ejecuta mediante `uv run deepslop`:

```bash
# Verificar la instalación del motor
uv run deepslop --help

# Ejecutar sonda de inspección de hardware en la máquina local
uv run deepslop probe

# Consultar estadísticas globales del catálogo
uv run deepslop catalog stats

# Buscar perfiles disponibles por fabricante o modelo
uv run deepslop catalog search "thinkpad"
uv run deepslop catalog search "xps"
uv run deepslop catalog search "vivobook"
```

### 2.2. Sincronización y Regeneración del Catálogo
Para regenerar los scripts o actualizar la base de datos a partir de los feeds oficiales:
```bash
# Sincronizar todos los catálogos de fabricantes
uv run deepslop catalog sync --vendor all

# Generar la matriz completa de paridad de scripts en fixes/
uv run deepslop generate-fixes --all
```

---

## 3. Compilación e Instalación de Módulos de Kernel

Para compilar un controlador específico de hardware out-of-tree (ejemplo de teclado LampArray):

```bash
cd fixes/<modelo>/kmod/ # o dentro de la carpeta del módulo C
make KVER=$(uname -r)
```

Para instalarlo en el sistema y actualizar dependencias del kernel:
```bash
sudo make install
sudo depmod -a $(uname -r)
```

---

## 4. Hook de Pacman para Kernel Rolling-Release

Para distribuciones rolling-release (Arch, CachyOS, Manjaro), los módulos out-of-tree deben recompilarse automáticamente en cada actualización del kernel mediante un hook de ALPM:

```ini
# /etc/pacman.d/hooks/99-codex-kmod.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Path
Target = usr/lib/modules/*/vmlinuz

[Action]
Description = Recompilando módulos de kernel CodexCompatibilitas para la nueva versión...
When = PostTransaction
Exec = /bin/sh -c 'for d in /usr/lib/modules/*/build; do kver=$(basename $(dirname "$d")); make -C "/ruta/al/driver" KVER="$kver" && mkdir -p "/usr/lib/modules/$kver/updates" && cp -f "/ruta/al/driver/modulo.ko" "/usr/lib/modules/$kver/updates/" && depmod -a "$kver"; done'
NeedsTargets
```
