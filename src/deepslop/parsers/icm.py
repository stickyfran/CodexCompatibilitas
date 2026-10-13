import os
import struct
from typing import Optional, Dict


class ICMProfileInfo:
    def __init__(self, file_path: str):
        self.file_path = file_path
        self.description = ""
        self.device_class = ""
        self.color_space = ""
        self._parse()

    def _parse(self):
        try:
            with open(self.file_path, "rb") as f:
                header = f.read(128)
                if len(header) < 128:
                    return

                # Bytes 12-16: Device class (ej: 'mntr')
                self.device_class = header[12:16].decode("ascii", errors="ignore")
                # Bytes 16-20: Color space (ej: 'RGB ')
                self.color_space = header[16:20].decode("ascii", errors="ignore")

                # Buscar tag 'desc' en el cuerpo
                f.seek(128)
                tag_count_raw = f.read(4)
                if len(tag_count_raw) == 4:
                    tag_count = struct.unpack(">I", tag_count_raw)[0]
                    for _ in range(tag_count):
                        tag_data = f.read(12)
                        if len(tag_data) < 12:
                            break
                        sig, offset, size = struct.unpack(">4sII", tag_data)
                        if sig == b"desc":
                            f.seek(offset)
                            desc_content = f.read(size)
                            # Tag desc suele tener tipo 'desc' seguido de longitud ASCII
                            if len(desc_content) >= 12 and desc_content[:4] == b"desc":
                                ascii_len = struct.unpack(">I", desc_content[8:12])[0]
                                self.description = desc_content[12:12+ascii_len].decode("latin-1", errors="ignore").rstrip("\x00")
                            break
        except Exception:
            pass

    def install_for_user(self) -> str:
        dest_dir = os.path.expanduser("~/.local/share/icc")
        filename = os.path.basename(self.file_path)
        dest_path = os.path.join(dest_dir, filename)

        return f"""mkdir -p {dest_dir}
cp "{self.file_path}" "{dest_path}"
colormgr import-profile "{dest_path}"
"""
