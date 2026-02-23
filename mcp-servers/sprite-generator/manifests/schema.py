"""Manifest schema validation."""

import sys
import yaml
from typing import Dict, List, Any


class ManifestValidator:
    """Validates sprite generation manifests."""
    
    REQUIRED_FIELDS = ['name', 'entity', 'action']
    OPTIONAL_FIELDS = ['variations', 'size', 'style', 'view', 'details']
    
    @staticmethod
    def load_and_validate(manifest_path: str) -> List[Dict[str, Any]]:
        """Load and validate a manifest file.
        
        Args:
            manifest_path: Path to YAML manifest file
            
        Returns:
            List of validated sprite specifications
            
        Raises:
            FileNotFoundError: If manifest doesn't exist
            ValueError: If manifest is invalid
        """
        try:
            with open(manifest_path, 'r') as f:
                data = yaml.safe_load(f)
        except FileNotFoundError:
            raise FileNotFoundError(f"Manifest not found: {manifest_path}")
        except yaml.YAMLError as e:
            raise ValueError(f"Invalid YAML in manifest: {e}")
        
        # Check if data is a list
        if not isinstance(data, list):
            # Maybe it's wrapped in a 'sprites' key
            if isinstance(data, dict) and 'sprites' in data:
                data = data['sprites']
            else:
                raise ValueError("Manifest must be a list of sprite specifications")
        
        # Validate each sprite spec
        validated = []
        for i, spec in enumerate(data):
            try:
                ManifestValidator._validate_spec(spec, i)
                validated.append(spec)
            except ValueError as e:
                print(f"Warning: Skipping invalid sprite #{i}: {e}", file=sys.stderr)
        
        if not validated:
            raise ValueError("No valid sprite specifications found in manifest")
        
        return validated
    
    @staticmethod
    def _validate_spec(spec: Dict[str, Any], index: int) -> None:
        """Validate a single sprite specification.
        
        Args:
            spec: Sprite specification dictionary
            index: Index in manifest (for error messages)
            
        Raises:
            ValueError: If spec is invalid
        """
        if not isinstance(spec, dict):
            raise ValueError(f"Sprite #{index} must be a dictionary")
        
        # Check required fields
        for field in ManifestValidator.REQUIRED_FIELDS:
            if field not in spec:
                raise ValueError(f"Sprite #{index} missing required field: {field}")
        
        # Validate size if present
        if 'size' in spec:
            size = spec['size']
            if not isinstance(size, list) or len(size) != 2:
                raise ValueError(
                    f"Sprite #{index} 'size' must be [width, height], got: {size}"
                )
            if not all(isinstance(x, int) and x > 0 for x in size):
                raise ValueError(
                    f"Sprite #{index} 'size' must be positive integers, got: {size}"
                )
        
        # Validate variations if present
        if 'variations' in spec:
            variations = spec['variations']
            if not isinstance(variations, int) or variations < 1:
                raise ValueError(
                    f"Sprite #{index} 'variations' must be positive integer, got: {variations}"
                )
