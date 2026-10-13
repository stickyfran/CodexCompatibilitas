# ASUS Vivobook S 15 OLED (`S5506MA`) — Modelo Cero

> **Estado general:** `100% OPERATIVO / PARIDAD WINDOWS COMPLETA`  
> **Validación:** Probado y validado en hardware real sobre Arch Linux / Kernel 6.13+ con cero procesos residentes en segundo plano.

---

## 1. Identificadores de Hardware (Hardware Matching)

| Campo | Valor |
| :--- | :--- |
| **Fabricante DMI** | `ASUSTeK COMPUTER INC.` |
| **Producto DMI** | `ASUS Vivobook S 15 S5506MA_S5506MA` |
| **Placa (Board Name)** | `S5506MA` |
| **Versión BIOS** | `S5506MA.318` |
| **Procesador** | Intel Core Ultra 7 155H (Meteor Lake) |
| **Audio Subsystem** | `PCI\VEN_8086&DEV_7E28&SUBSYS_10433C10` |
| **Codec de Audio** | Realtek ALC294 (`10EC:0294`) |
| **Panel OLED (EDID)** | Samsung Display `SDC4180` (2880x1620 @ 120Hz) |
| **Teclado RGB (HID)** | `0B05:19B6` (LampArray HID Device) |

---

## 2. Matriz de Componentes y Estado

| Componente | Estado Linux OOTB | Estado DeepSlop | Solución / Fix Nativo |
| :--- | :---: | :---: | :--- |
| **Audio Altavoces** | 🟡 Plano, sin bajos, volumen bajo | 🟢 **Fixed** | PipeWire Filter-Chain con ecualización paramétrica Dolby Atmos de fábrica |
| **Micrófono** | 🟢 Funciona | 🟢 **OOTB** | Driver Intel SOF nativo |
| **Pantalla OLED** | 🟡 Sin perfil calibrado | 🟢 **Fixed** | Perfil de color Splendid oficial (`.icm`) importado en `colord` por EDID |
| **Teclado RGB** | 🔴 Solo rojo fijo o no responde | 🟢 **Fixed** | Módulo de kernel LampArray con soporte de suspensión, hotkey F4 y FN-Lock |
| **Hotkeys (F1-F12)** | 🟡 Brillo y volumen bien, F4 inerte | 🟢 **Fixed** | Integrado en driver LampArray vía listeners WMI directos |
| **Control Térmico** | 🟢 Modos de ventilador vía WMI | 🟢 **Fixed** | Modos Whisper / Standard / Performance controlables por sysfs |
| **Lector Huellas** | ⚪ No presente | ⚪ **Absent** | Modelo sin sensor de huellas |

---

## 3. Paquetes Oficiales de Drivers Analizados

* **Audio:** `Audio_Realtek_DCH_ROG_Intel_Z_V6.0.9635.1_36683.exe`  
  * CDN Oficial: `https://dlcdnets.asus.com/pub/ASUS/nb/Image/Driver/Audio/36683/Audio_Realtek_DCH_ROG_Intel_Z_V6.0.9635.1_36683.exe`
  * Extracción: Curvas acústicas DAP XML específicas para chasis `S5506MA` y codec ALC294.
* **Color / Utilidades:** `ASUSSystemControlInterfacev3_ASUS_Z_V3.1.32.0_37280.exe`  
  * CDN Oficial: `https://dlcdnets.asus.com/pub/ASUS/nb/Image/Driver/SoftwareUtility/37280/ASUSSystemControlInterfacev3_ASUS_Z_V3.1.32.0_37280.exe`
  * Extracción: Perfil `S5506MA_8086_834C4180.icm` para panel Samsung `SDC4180`.

---

## 4. Instalación de Fixes en un Solo Paso

```bash
# Ejecutar desde el CLI de DeepSlopSuperLaptop
uv run deepslop process asus-vivobook-s-15-oled-s5506ma
```
O aplicar los componentes individuales verificados desde el repositorio base:
* Audio PipeWire: `~/.config/pipewire/pipewire.conf.d/99-asus-s5506ma-speakers.conf`
* Perfil de color: `colormgr import-profile S5506MA_8086_834C4180.icm`
* Teclado RGB LampArray: `/home/kes/Documentos/Programando/colores/asus-lamparray-kmod/install.sh`
