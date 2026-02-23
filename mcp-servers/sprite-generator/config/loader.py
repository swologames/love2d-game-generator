"""Configuration loader for sprite generator."""

import os
import sys
import yaml
from typing import Dict, Any, Optional


class ConfigLoader:
    """Loads and validates configuration from YAML file."""
    
    def __init__(self, config_path: str):
        """Initialize config loader.
        
        Args:
            config_path: Path to config.yaml file
        """
        self.config_path = config_path
        self.config: Dict[str, Any] = {}
    
    def load(self) -> Dict[str, Any]:
        """Load configuration from YAML file.
        
        Returns:
            Configuration dictionary
            
        Raises:
            FileNotFoundError: If config file doesn't exist
            yaml.YAMLError: If config file is invalid YAML
        """
        if not os.path.exists(self.config_path):
            raise FileNotFoundError(f"Config file not found: {self.config_path}")
        
        with open(self.config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        
        # Apply environment variable overrides
        self._apply_env_overrides()
        
        # Expand paths
        self._expand_paths()
        
        return self.config
    
    def _apply_env_overrides(self) -> None:
        """Apply environment variable overrides."""
        # OpenAI API key
        if 'OPENAI_API_KEY' in os.environ:
            if 'providers' not in self.config:
                self.config['providers'] = {}
            if 'openai' not in self.config['providers']:
                self.config['providers']['openai'] = {}
            self.config['providers']['openai']['api_key'] = os.environ['OPENAI_API_KEY']
    
    def _expand_paths(self) -> None:
        """Expand ~ and environment variables in paths."""
        if 'providers' in self.config:
            if 'local_sd' in self.config['providers']:
                sd_config = self.config['providers']['local_sd']
                if 'cache_dir' in sd_config:
                    sd_config['cache_dir'] = os.path.expanduser(sd_config['cache_dir'])
        
        if 'paths' in self.config:
            for key, value in self.config['paths'].items():
                if isinstance(value, str):
                    self.config['paths'][key] = os.path.expanduser(value)
    
    def get_provider_config(self, provider_name: str) -> Optional[Dict[str, Any]]:
        """Get configuration for a specific provider.
        
        Args:
            provider_name: Provider name (e.g., 'openai', 'local_sd')
            
        Returns:
            Provider configuration dict or None if not found
        """
        providers = self.config.get('providers', {})
        return providers.get(provider_name)
    
    def get_defaults(self) -> Dict[str, Any]:
        """Get default generation parameters."""
        return self.config.get('defaults', {})
    
    def get_postprocess_config(self) -> Dict[str, Any]:
        """Get post-processing configuration."""
        return self.config.get('postprocess', {})
    
    def get_workspace_root(self) -> str:
        """Get workspace root path."""
        paths = self.config.get('paths', {})
        return paths.get('workspace_root', os.getcwd())
