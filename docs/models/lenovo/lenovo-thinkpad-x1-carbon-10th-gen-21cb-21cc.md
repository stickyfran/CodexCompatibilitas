# Lenovo ThinkPad X1 Carbon Gen 10 — Ficha Técnica

> **Estado general:** `SOPORTADO EN PIPELINE DEEP SLOP`  
> **Machine Types (MTM):** `21CB`, `21CC`  
> **Arquitectura:** Intel Core 12th Gen Alder Lake

---

## 1. Identificadores de Hardware (Hardware Matching)

| Campo | Valor |
| :--- | :--- |
| **Fabricante DMI** | `LENOVO` |
| **Familia** | ThinkPad X1 Carbon 10th Gen |
| **Machine Types (MTM)** | `21CB`, `21CC` |
| **Audio** | Realtek ALC3306 + DSP Dolby Atmos Quad-Speaker |
| **Cámara** | MIPI IPU6 o USB UVC con sensor IR Computer Vision |
| **TrackPoint / Touchpad** | Synaptics / ELAN TrackPoint nativo |

---

## 2. Diagnóstico de Componentes en Linux

* **Audio:**
  * *Problema OOTB:* Sin perfil de ecualización los 4 altavoces (2 woofers hacia abajo + 2 tweeters hacia arriba) suenan desbalanceados y metálicos.
  * *Solución DeepSlop:* Curvas DAP XML de 4 canales traducidas a PipeWire filter-chain con crossover activo.
* **Cámara MIPI (modelos con Computer Vision):**
  * Requiere stack `ipu6-drivers` + blobs de sensor extraídos del driver de Windows.
* **TrackPoint y botones:**
  * Soportados de forma nativa por el kernel en `thinkpad_acpi` y `psmouse`.
