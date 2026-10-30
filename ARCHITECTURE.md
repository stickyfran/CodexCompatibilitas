# Especificación Arquitectónica (ARCHITECTURE.md)

Este documento detalla el diseño de ingeniería, los principios rectores y la arquitectura técnica de **CodexCompatibilitas**.

---

## 1. Principios de Diseño

1. **Regla de Cero Daemons Residentes (Zero-Daemon Rule):**  
   Los procesos en segundo plano consumen ciclos de CPU, mantienen despiertos los estados C de energía e impactan drásticamente la autonomía de la batería en equipos portátiles. Cualquier soporte de hardware debe implementarse mediante:
   - Controladores nativos del kernel (C) que aprovechan las interrupciones del hardware.
   - Nodos estándar en `sysfs` (`/sys/class/leds`, `/sys/firmware/acpi`).
   - Cadenas de filtros DSP en espacio de usuario pasivos (`node.passive = true` en PipeWire), suspendidos automáticamente cuando no hay reproducción activa.
   - Servicios de inicialización de un solo disparo (`Type=oneshot` en systemd) que duran `<1 ms` durante el arranque y el apagado.

2. **Deduplicación Criptográfica y Escalabilidad:**  
   Indexar más de 10.000 modelos de portátiles requiere evitar redundancias masivas de almacenamiento. Los paquetes binarios compartidos por un fabricante (como perfiles de ecualización Realtek, firmwares o curvas de ventilador) se indexan por hash SHA-256 en una base de datos relacional liviana (`SQLite`), desacoplando la definición del modelo del archivo físico.

3. **Independencia de Windows:**  
   No se requiere bootear Windows ni utilizar máquinas virtuales para acceder a la calibración del fabricante. Todo el flujo se sustenta en descompilación de archivos ejecutables, decodificación de tablas ACPI y mapeo inverso de protocolos HID/WMI directamente en Linux.

---

## 2. Diagrama de Capas del Sistema

```
+-----------------------------------------------------------------------------------+
|                            ESPACIO DE USUARIO (APPS)                              |
|   Navegador Web / Reproductores / IDE / Juegos / Llamadas (Discord, WebRTC)       |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                         SUBSISTEMA DE AUDIO (PIPEWIRE)                            |
|   [ 99-audio.conf ] Filtro Paramétrico Biquad (20 bandas Dolby Atmos / Harman)    |
|   - Conexión dinámica (filter.smart = true)                                       |
|   - Suspensión a 0 mW cuando no hay flujo de audio (node.passive = true)          |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                        CONTROL DE PANTALLA Y COLOR (WAYLAND)                      |
|   [ colord / KWin / GNOME ] Perfiles de Color Calibrados por Fábrica (.icm/.icc)  |
|   - Asignación por EDID exacto del panel OLED/IPS                                 |
|   - Mapeo de espacios: sRGB, Display P3, DCI-P3                                    |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                         INTERFAZ DEL KERNEL DE LINUX                              |
|   /sys/class/leds/asus::kbd_backlight_rgb/...   /sys/firmware/acpi/platform_profile|
|   /sys/class/powercap/intel-rapl/              /dev/input/event*                  |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                      MÓDULOS DEL KERNEL Y DRIVERS NATIVOS                         |
|   - Controlador HID LampArray / Hotkeys (C)                                       |
|   - Driver WMI del fabricante (asus-wmi, thinkpad_acpi, dell-wmi, hp-wmi)         |
|   - Driver de GPU DRM (i915, xe, amdgpu) con PSR2, FBC y Deep C-States            |
|   - thermald (lectura de tablas GDDV/DPTF en ACPI)                                 |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                            HARDWARE & MICROCONTROLADORES                          |
|   Embedded Controller (EC) / Codec Realtek / Panel OLED / Sensores I2C-HID        |
+-----------------------------------------------------------------------------------+
```

---

## 3. Desglose de Subsistemas

### 3.1. Subsistema de Audio (Audio DSP & Microphones)
- **Problemática habitual:** En Linux, los altavoces de las computadoras portátiles suenan planos o carecen de volumen porque las capas DSP propietarias (Dolby Atmos, Waves MaxxAudio, Bang & Olufsen, DTS:X) solo vienen configuradas en el driver de Windows.
- **Solución arquitectónica:**
  1. Se extrae la curva de calibración de carcasa medida por el fabricante (encontrada en archivos XML o archivos de datos como `RTAIODAT.DAT`).
  2. Se calculan los coeficientes biquad (frecuencia central $f_0$, ganancia $G$ en dB y factor de calidad $Q$).
  3. Se genera un archivo de configuración para PipeWire (`filter-chain`) que inserta un ecualizador paramétrico transparente delante del *sink* físico de los altavoces.
  4. Si se conectan auriculares (jack de 3.5mm o Bluetooth), PipeWire conmuta automáticamente el destino sin aplicarle la compensación de los altavoces internos.
  5. En el micrófono, se agregan filtros notch o peaking para atenuar siseos mecánicos o resonancias del chasis de la pantalla.

### 3.2. Subsistema Visual y Pantallas OLED / Wide-Gamut
- **Problemática habitual:** Paneles OLED de alta gama muestran colores sobresaturados o fluorescentes en contenido web estándar porque el escritorio asume sRGB en un panel con cobertura DCI-P3 al 100%.
- **Solución arquitectónica:**
  - Se vincula el modelo y panel mediante el identificador EDID de la pantalla (ej. `SDC4180` en Samsung OLED).
  - Se extraen de los paquetes del fabricante (ej. ASUS Splendid, Lenovo Color Management, Dell PremierColor) los perfiles ICC/ICM calibrados en la línea de montaje de fábrica.
  - Se registran en `colord` para que Wayland gestione el gamut mapping de forma fidedigna.

### 3.3. Subsistema de Control Térmico y Gestión de Energía
- **Problemática habitual:** El ventilador se dispara erráticamente o el equipo no alcanza su rendimiento térmico diseñado (TDP sostenido PL1 / PL2) al carecer de la suite Intel DPTF (*Dynamic Platform and Thermal Framework*).
- **Solución arquitectónica:**
  - Las tablas de diseño térmico pasivo (`PSVT`, `GDDV`) están grabadas en los bloques ACPI de la BIOS de la placa madre.
  - Mediante `thermald --adaptive` se leen estas tablas directamente del hardware, respetando los umbrales de temperatura de piel/superficie del chasis fijados por los ingenieros del fabricante.
  - Se integra con `power-profiles-daemon` mediante la interfaz `platform_profile` del kernel (`low-power`, `balanced`, `performance`), sincronizando las curvas del ventilador del chip EC sin requerir utilidades pesadas en espacio de usuario.

### 3.4. Teclado, Iluminación RGB y Hotkeys
- **Problemática habitual:** Teclados con control LampArray (protocolo USB HID `0x0059`) o teclas especiales (Fn+Esc / Fn-Lock, teclas de brillo de teclado) no son reconocidos por el driver estándar del kernel o pierden su estado al reiniciar.
- **Solución arquitectónica:**
  - Desarrollo de drivers nativos del kernel en C (como `hid-asus-lamparray.c`) que exponen directamente atributos estándar en `/sys/class/leds/`.
  - Escucha de eventos WMI del teclado físico mediante `input_handler` en el espacio de kernel para reaccionar a scancodes propios del fabricante (ej. `0xeb` en ASUS).
  - Persistencia de estados volátiles mediante scripts *oneshot* que solo registran el último estado en disco al apagar y lo reinyectan al arrancar, completando la operación en menos de 1 milisegundo sin ningún daemon en memoria.

---

## 4. Pipeline de Procesamiento del Catálogo (`deepslop`)

El motor en [`src/deepslop/`](src/deepslop/) está estructurado en módulos desacoplados:

1. **`catalogs/`:** Clientes especializados para consultar e indexar los catálogos empresariales (SCCM CABs de Dell, XML SoftPaq de HP, bases CDRT de Lenovo y endpoints REST de ASUS).
2. **`parsers/`:** Módulos para parsear descriptores ACPI, volcados de registro, archivos `.inf`, contenedores XML de audio y mapas térmicos `.dv`.
3. **`generators/`:** Generadores de código y scripts bash automatizados `install-all.sh` que combinan la configuración de audio, perfiles de color, drivers de kernel y comandos térmicos correspondientes a cada modelo.
4. **`probe/`:** Herramienta de detección de hardware en caliente que lee DMI (`/sys/class/dmi/id/`), codecs de audio HDA/SOF y tablas ACPI locales para recomendar el paquete exacto para la laptop en uso.
