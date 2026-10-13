from abc import ABC, abstractmethod
from typing import List, AsyncGenerator
from deepslop.models import LaptopModel


class BaseCatalog(ABC):
    """Interfaz base para proveedores de catálogos OEM."""

    @property
    @abstractmethod
    def vendor_name(self) -> str:
        """Nombre del fabricante (Lenovo, Dell, HP, ASUS, etc.)."""
        pass

    @abstractmethod
    async def fetch_catalog(self, cache_dir: str) -> List[LaptopModel]:
        """Descarga e indexa los modelos del catálogo."""
        pass
