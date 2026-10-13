# Documentación de Modelos — DeepSlopSuperLaptop

Este directorio contiene las fichas técnicas y el estado de compatibilidad de los **1.816 modelos indexados**, organizados por fabricante:

* [ASUS](asus/README.md): Vivobook (S15, S14, Pro), Zenbook (14X, Duo), ROG (Zephyrus, Strix), TUF Gaming, ExpertBook.
* [Dell](dell/README.md): XPS (13, 15, 17), Latitude, Precision, Inspiron, Alienware.
* [Lenovo](lenovo/README.md): ThinkPad (X1 Carbon, T, P, X13, Yoga), ThinkBook, Legion.
* [HP](hp/README.md): EliteBook (830, 840, 1040, x360), ProBook, ZBook, Spectre, Dragonfly.

---

## 🧭 Estructura de cada Ficha de Modelo

Cada ficha técnica de una laptop documenta:
1. **Identificadores de Hardware:** DMI `product_name`, `board_name`, `systemID` / `MTM`, PCI Subsystem IDs (`VEN_xxxx&DEV_xxxx&SUBSYS_xxxx`).
2. **Matriz de Componentes:** Estado (`works-ootb`, `fixed`, `partial`, `broken`, `absent`).
3. **Paquetes Oficiales OEM:** Enlaces HTTP a los drivers de Windows analizados y hashes MD5/SHA256.
4. **Fixes Nativos Aplicados:** Sin procesos en segundo plano:
   - **Audio:** Perfil PipeWire filter-chain (`filter.smart`) o firmware Cirrus Logic en `/lib/firmware/cirrus/`.
   - **Color:** Perfil de color `.icm` oficial importado en `colord`.
   - **Teclado / Hotkeys:** Mapeo de teclas en `60-keyboard.hwdb` o módulo HID.
   - **Sensores:** Matriz de rotación en `60-sensor.hwdb`.
