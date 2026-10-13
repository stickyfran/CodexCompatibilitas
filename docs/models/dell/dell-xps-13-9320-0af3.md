# Dell XPS 13 Plus 9320 — Ficha Técnica

> **Estado general:** `SOPORTADO EN PIPELINE DEEP SLOP`  
> **Arquitectura:** Intel Core 12th/13th Gen (Alder Lake / Raptor Lake)  
> **SystemID Dell:** `0AF3`, `0C10`

---

## 1. Identificadores de Hardware (Hardware Matching)

| Campo | Valor |
| :--- | :--- |
| **Fabricante DMI** | `Dell Inc.` |
| **Producto DMI** | `XPS 13 Plus 9320` |
| **SystemIDs** | `0AF3`, `0C10` |
| **Audio Amps** | Cirrus Logic CS35L41 (Amplificadores I2C/SPI para 4 altavoces) |
| **Touchpad** | Haptic Touchpad Sensel / Microchip |
| **Teclado** | Barra táctil capacitiva de funciones |

---

## 2. Diagnóstico de Componentes en Linux

* **Audio Altavoces:**
  * *Problema OOTB:* En kernels anteriores a 6.8 o sin firmware específico, los 4 altavoces quedan mudos o solo suena el tweeter a un 5% de volumen.
  * *Solución DeepSlop:* Firmware `cs35l41-dsp1-spk-prot.wmfw` y tablas de coeficientes `cs35l41-dsp1-spk-prot-10280af3.bin` extraídas directamente del DriverPack de Dell hacia `/lib/firmware/cirrus/`.
* **Touchpad Háptico:** Funciona mediante driver `i2c_designware` y `hid_multitouch`.
* **Barra de funciones táctil:** Controlada por controlador embebido de Dell (Dell SMBIOS WMI).

---

## 3. Paquetes Oficiales de Drivers Catalogados

* **Dell Driver Pack (Windows 11):**
  * Descarga oficial: `https://downloads.dell.com/FOLDER.../XPS-9320-Win11.CAB`
  * Firmware CS35L41 incluido en paquete de audio Realtek DCH.
