"""Base class for image generation providers."""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from PIL import Image


class ImageProvider(ABC):
    """Abstract base class for AI image generation providers."""
    
    def __init__(self, config: Dict[str, Any]):
        """Initialize provider with configuration.
        
        Args:
            config: Provider-specific configuration dictionary
        """
        self.config = config
        self._initialized = False
    
    @abstractmethod
    def initialize(self) -> None:
        """Initialize the provider (load models, connect to API, etc.).
        
        Raises:
            RuntimeError: If initialization fails
        """
        pass
    
    @abstractmethod
    def generate(
        self,
        prompt: str,
        negative_prompt: Optional[str] = None,
        width: int = 512,
        height: int = 512,
        **kwargs
    ) -> Image.Image:
        """Generate an image from a text prompt.
        
        Args:
            prompt: Text description of the image to generate
            negative_prompt: Things to avoid in the generation
            width: Output image width in pixels
            height: Output image height in pixels
            **kwargs: Provider-specific parameters
            
        Returns:
            PIL Image object
            
        Raises:
            RuntimeError: If generation fails
        """
        pass
    
    @abstractmethod
    def cleanup(self) -> None:
        """Clean up resources (unload models, close connections, etc.)."""
        pass
    
    @property
    def is_initialized(self) -> bool:
        """Check if provider is initialized and ready to use."""
        return self._initialized
    
    @property
    @abstractmethod
    def name(self) -> str:
        """Get the provider name."""
        pass
