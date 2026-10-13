import os
import xml.etree.ElementTree as ET
from typing import List, Dict, Any, Optional
from pydantic import BaseModel


class BiquadFilter(BaseModel):
    type: str  # "bq_peaking", "bq_highpass", "bq_lowpass"
    freq: float
    q: float
    gain: float  # dB


class AudioEQProfile(BaseModel):
    name: str
    vendor: str
    subsys: str
    preamp_gain_db: float = 0.0
    filters: List[BiquadFilter] = []


def parse_dolby_xml(xml_content: str) -> Optional[AudioEQProfile]:
    """Parsea un archivo de calibración Dolby Atmos OEM XML (DAP / DAX3)."""
    try:
        root = ET.fromstring(xml_content)
    except Exception:
        return None

    # Buscar perfiles o tuning
    filters: List[BiquadFilter] = []
    preamp = 0.0

    # DAX3 o DAP XML suelen tener nodos <GraphicEq>, <ParametricEq>, <SpeakerTuning>, etc.
    # Buscamos nodos de ecualización paramétrica
    for peq in root.iter():
        tag = peq.tag.lower()
        if "peq" in tag or "filter" in tag or "band" in tag:
            freq_str = peq.attrib.get("freq") or peq.attrib.get("frequency")
            q_str = peq.attrib.get("q") or peq.attrib.get("bandwidth")
            gain_str = peq.attrib.get("gain") or peq.attrib.get("gain_db")

            if freq_str and q_str and gain_str:
                try:
                    f = float(freq_str)
                    q = float(q_str)
                    g = float(gain_str)
                    filters.append(BiquadFilter(type="bq_peaking", freq=f, q=q, gain=g))
                except ValueError:
                    pass

    if not filters:
        return None

    return AudioEQProfile(
        name="Dolby Factory Tuning",
        vendor="OEM",
        subsys="auto",
        preamp_gain_db=preamp,
        filters=filters,
    )


def generate_pipewire_filter_chain(profile: AudioEQProfile, sink_name: str = "oem_speakers_eq") -> str:
    """Genera una configuración nativa de PipeWire filter-chain (.conf) sin daemons."""
    nodes = []
    links = []

    # Construir nodos biquad para cada canal (L y R)
    for i, f in enumerate(profile.filters):
        node_l = f"""        {{
            type  = builtin
            name  = eq_l_{i}
            label = {f.type}
            control = {{
                "Freq" = {f.freq}
                "Q"    = {f.q}
                "Gain" = {f.gain}
            }}
        }}"""
        node_r = f"""        {{
            type  = builtin
            name  = eq_r_{i}
            label = {f.type}
            control = {{
                "Freq" = {f.freq}
                "Q"    = {f.q}
                "Gain" = {f.gain}
            }}
        }}"""
        nodes.extend([node_l, node_r])

    nodes_str = ",\n".join(nodes)

    config = f"""# Generado automáticamente por DeepSlopSuperLaptop
# Calibración de fábrica OEM para {profile.name} ({profile.subsys})
# Ubicación recomendada: ~/.config/pipewire/pipewire.conf.d/99-{sink_name}.conf

context.modules = [
    {{
        name = libpipewire-module-filter-chain
        args = {{
            node.description = "Altavoces ({profile.name})"
            media.name       = "Altavoces ({profile.name})"
            filter.graph = {{
                nodes = [
{nodes_str}
                ]
            }}
            audio.channels = 2
            audio.position = [ FL, FR ]
            capture.props = {{
                node.name        = "{sink_name}_in"
                media.class      = Audio/Sink
                audio.position   = [ FL, FR ]
            }}
            playback.props = {{
                node.name        = "{sink_name}_out"
                node.passive     = true
                audio.position   = [ FL, FR ]
            }}
        }}
    }}
]
"""
    return config
