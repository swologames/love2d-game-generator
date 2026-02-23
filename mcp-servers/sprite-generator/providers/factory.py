"""Provider factory for creating image generation providers."""

import sys
from typing import Dict, Any
from .base import ImageProvider
from .openai_provider import OpenAIProvider
from .sd_local_provider import LocalSDProvider


class ProviderFactory:
    """Factory for creating and managing image generation providers."""
    
    # Registry of available providers
    _providers = {
        'openai': OpenAIProvider,
        'local_sd': LocalSDProvider,
    }
    
    @classmethod
    def create(cls, provider_name: str, config: Dict[str, Any]) -> ImageProvider:
        """Create a provider instance.
        
        Args:
            provider_name: Name of the provider ('openai' or 'local_sd')
            config: Provider configuration dictionary
            
        Returns:
            Initialized ImageProvider instance
            
        Raises:
            ValueError: If provider name is unknown
            RuntimeError: If provider initialization fails
        """
        if provider_name not in cls._providers:
            available = ', '.join(cls._providers.keys())
            raise ValueError(
                f"Unknown provider: {provider_name}. Available: {available}"
            )
        
        provider_class = cls._providers[provider_name]
        
        try:
            provider = provider_class(config)
            provider.initialize()
            return provider
        except Exception as e:
            print(f"Failed to create provider '{provider_name}': {e}", file=sys.stderr)
            raise
    
    @classmethod
    def list_providers(cls) -> list:
        """List all available provider names."""
        return list(cls._providers.keys())
