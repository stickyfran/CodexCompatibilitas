from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field


class DriverRef(BaseModel):
    category: str = Field(..., description="Categoría (Audio, Chipset, Touchpad, Camera, etc.)")
    name: str
    version: Optional[str] = None
    url: str
    sha256: Optional[str] = None
    md5: Optional[str] = None
    size_bytes: Optional[int] = None
    release_date: Optional[str] = None
    hardware_ids: List[str] = Field(default_factory=list)


class DriverPackRef(BaseModel):
    name: str
    os: str
    url: str
    size_bytes: Optional[int] = None
    md5: Optional[str] = None
    sha256: Optional[str] = None
    version: Optional[str] = None
    release_date: Optional[str] = None


class ComponentStatus(BaseModel):
    status: str = Field(..., description="works-ootb | fixed | partial | broken | absent | unknown")
    fix_type: Optional[str] = None
    fix_path: Optional[str] = None
    details: Dict[str, Any] = Field(default_factory=dict)


class LaptopModel(BaseModel):
    id: str = Field(..., description="ID canónico, ej: lenovo-thinkpad-x1-carbon-gen-10")
    vendor: str
    family: Optional[str] = None
    model_name: str
    system_id: Optional[str] = None  # Dell SystemID, Lenovo MTM, etc.
    dmi_matches: List[str] = Field(default_factory=list)
    driver_packs: List[DriverPackRef] = Field(default_factory=list)
    individual_drivers: List[DriverRef] = Field(default_factory=list)
    components: Dict[str, ComponentStatus] = Field(default_factory=dict)
