#!/usr/bin/env python3
"""
Script de diagnóstico e inspección de bajo nivel para el controlador
ITE5570 HID LampArray (0018:0B05:19B6) en el ASUS Vivobook S 15 OLED (S5506MA).

Lee y decodifica los Feature Reports descubiertos en el descriptor HID:
 - Report ID 0x01 (LampArrayAttributesReport, Usage Page 0x0059)
 - Report ID 0x03 (LampAttributesResponseReport, Usage Page 0x0059)
 - Report ID 0x5F (ASUS Vendor Page 0xFF30)
"""
import fcntl
import glob
import os
import struct


def hidiocgfeature(length: int) -> int:
    return (3 << 30) | (length << 16) | (ord("H") << 8) | 0x07


def find_asus_lamparray_hidraw() -> str:
    for syspath in sorted(glob.glob("/sys/class/hidraw/hidraw*")):
        uevent_path = os.path.join(syspath, "device", "uevent")
        if os.path.exists(uevent_path):
            with open(uevent_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            if "00000B05:000019B6" in content or "00000B05:00005570" in content:
                return f"/dev/{os.path.basename(syspath)}"
    raise FileNotFoundError("No se encontró el dispositivo ITE5570 (0B05:19B6 / 0B05:5570)")


def main() -> None:
    dev = find_asus_lamparray_hidraw()
    print(f"[*] Dispositivo encontrado: {dev}")
    fd = os.open(dev, os.O_RDWR)
    try:
        # Report 0x01: LampArrayAttributesReport (23 bytes)
        buf = bytearray(23)
        buf[0] = 0x01
        fcntl.ioctl(fd, hidiocgfeature(len(buf)), buf)
        lamp_count, width, height, depth, kind, min_interval = struct.unpack_from("<HIIIII", buf, 1)
        print("\n=== Report 0x01: LampArrayAttributesReport ===")
        print(f"  Raw Hex           : {bytes(buf).hex(' ')}")
        print(f"  LampCount         : {lamp_count} zona(s)")
        print(f"  Dimensiones (mm)  : {width/1000:.1f} x {height/1000:.1f} x {depth/1000:.1f} mm")
        print(f"  LampArrayKind     : {kind} (1 = Teclado)")
        print(f"  MinUpdateInterval : {min_interval} us ({min_interval/1000:.1f} ms)")

        # Report 0x03: LampAttributesResponseReport (26 bytes)
        buf3 = bytearray(26)
        buf3[0] = 0x03
        fcntl.ioctl(fd, hidiocgfeature(len(buf3)), buf3)
        lamp_id, pos_x, pos_y, pos_z, purpose, latency, r_lvls, g_lvls, b_lvls, i_lvls, prog, key = struct.unpack_from(
            "<HIIIIIBBBBBB", buf3, 1
        )
        print("\n=== Report 0x03: LampAttributesResponseReport ===")
        print(f"  Raw Hex           : {bytes(buf3).hex(' ')}")
        print(f"  LampId            : {lamp_id}")
        print(f"  Niveles R/G/B/Int : {r_lvls}/{g_lvls}/{b_lvls}/{i_lvls}")
        print(f"  IsProgrammable    : {bool(prog)}")

        # Report 0x5F: Vendor Page 0xFF30 (17 bytes)
        buf5f = bytearray(17)
        buf5f[0] = 0x5F
        fcntl.ioctl(fd, hidiocgfeature(len(buf5f)), buf5f)
        ascii_str = bytes(buf5f[1:]).decode("ascii", errors="replace").rstrip("\x00")
        print("\n=== Report 0x5F: Vendor Page 0xFF30 ===")
        print(f"  Raw Hex           : {bytes(buf5f).hex(' ')}")
        print(f"  Identificador EC  : '{ascii_str}'")
    finally:
        os.close(fd)


if __name__ == "__main__":
    main()
