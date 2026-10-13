# DeepSlopSuperLaptop 🚀

> Base de datos masiva y herramientas de interoperabilidad de hardware OEM para Linux.
> **Objetivo:** Lograr compatibilidad y calibración de fábrica (audio EQ, perfiles de color, curvas térmicas, hotkeys, sensores) para miles de laptops del mercado **sin daemons residentes que consuman batería**.

---

## 📊 Estado Actual de la Base de Datos

Ejecuta `uv run deepslop catalog stats`:

| Fabricante | Modelos Indexados | Paquetes de Drivers Catalogados |
| :--- | :---: | :---: |
| **Dell** (XPS, Latitude, Precision, Inspiron, Alienware) | **756** | ~2.500 |
| **HP** (EliteBook, ProBook, Spectre, Envy, ZBook, OMEN) | **512** | ~1.800 |
| **Lenovo** (ThinkPad, ThinkBook, Yoga, Legion) | **497** | ~1.900 |
| **ASUS** (Vivobook, Zenbook, ROG, TUF Gaming, ExpertBook) | **51** | ~50 |
| **TOTAL** | **1.816** | **6.218** |

---

## 💻 Uso Rápido

### 1. Inspeccionar el Hardware Local (Probe)
Detecta DMI, placas, BIOS, codecs de audio y dispositivos ACPI, y busca correspondencia automática en la base de datos:
```bash
uv run deepslop probe
```

### 2. Buscar Laptops en el Catálogo
```bash
uv run deepslop catalog search "xps 13"
uv run deepslop catalog search "thinkpad x1"
uv run deepslop catalog search "s5506ma"
```

### 3. Sincronizar Catálogos Oficiales
Descarga y procesa los índices de distribución empresarial de los OEMs (Dell SCCM CABs, HP SoftPaq XML, Lenovo CDRT, ASUS Sitemaps):
```bash
uv run deepslop catalog sync --vendor all
```

---

## 🛠️ Arquitectura

- **Modelo Cero (`S5506MA`):** Calibración completa de fábrica implementada y validada en hardware real:
  - Audio: PipeWire filter-chain con EQ paramétrico Dolby Atmos (`ALC294`).
  - Pantalla: Perfiles `.icm` Splendid vinculados por EDID (`SDC4180`).
  - Teclado: Módulo de kernel LampArray con soporte de suspensión, hotkey F4 y FN-lock nativo.
- **Pipeline de Análisis Masivo:** Deduplicación criptográfica (SHA-256) de paquetes de drivers para indexar componentes sin redundancia.
