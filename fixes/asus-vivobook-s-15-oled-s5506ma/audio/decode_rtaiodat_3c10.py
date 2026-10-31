#!/usr/bin/env python3
"""
Decodificador del bloque binario propietario Realtek RTAIODAT.DAT para
el ASUS Vivobook S 15 OLED S5506MA (PCI SUBSYS 0x10433C10, entrada 0x0A35).

Analiza el volcado `ASUS_3C10_RTAIODAT_dump.bin` (748 bytes extraídos desde
el offset 0x37938E0 de RTAIODAT.DAT V6.0.9828.1) y muestra los bloques
de calibración: MIEQ (ecualizador paramétrico de 10 bandas del micrófono),
MBEX, HFEQ y BF32.
"""
import os
import struct


def main() -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    bin_path = os.path.join(here, "ASUS_3C10_RTAIODAT_dump.bin")
    with open(bin_path, "rb") as f:
        chunk = f.read()

    print(f"[*] Analizando {bin_path} ({len(chunk)} bytes)")
    title = chunk[0x08:0x48].decode("utf-16le", errors="ignore").rstrip("\x00")
    print(f"[*] Identificador OEM en RTAIODAT.DAT: '{title}'")

    for sig in [b"MIEQ", b"MBEX", b"HFEQ", b"BF32"]:
        idx = chunk.find(sig)
        if idx == -1:
            continue
        ver, size = struct.unpack_from("<II", chunk, idx + 4)
        print(f"\n=== Bloque {sig.decode()} en offset +0x{idx:03x} (ver={ver}, size={size} bytes) ===")
        body = chunk[idx + 12 : idx + 12 + size]
        if sig == b"MIEQ" and len(body) >= 244:
            enabled = struct.unpack_from("<I", body, 0)[0]
            print(f"  Estado MIEQ: {'ACTIVO' if enabled else 'INACTIVO'}")
            for b in range(10):
                b_off = 4 + b * 24
                ftype, flag, fc, gain, q = struct.unpack_from("<IIddd", body, b_off)
                status = "ON " if flag else "OFF"
                print(f"  Banda {b+1:2d} [{status}]: Tipo={ftype} | Fc={fc:7.1f} Hz | Gain={gain:+5.1f} dB | Q={q:.2f}")


if __name__ == "__main__":
    main()
