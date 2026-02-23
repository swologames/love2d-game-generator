"""OpenAI DALL-E image generation provider."""

import os
import sys
from typing import Optional
from PIL import Image
import io
import base64

try:
    from openai import OpenAI
except ImportError:
    print("Warning: openai package not installed. Install with: pip install openai", file=sys.stderr)
    OpenAI = None

from .base import ImageProvider


class OpenAIProvider(ImageProvider):
    """OpenAI DALL-E 3 image generation provider."""
    
    def __init__(self, config: dict):
        super().__init__(config)
        self.client = None
        self.model = config.get('model', 'dall-e-3')
        self.quality = config.get('quality', 'standard')
        self.api_key = config.get('api_key') or os.getenv('OPENAI_API_KEY')
    
    def initialize(self) -> None:
        """Initialize OpenAI client."""
        if OpenAI is None:
            raise RuntimeError("openai package not installed. Run: pip install openai")
        
        if not self.api_key:
            raise RuntimeError(
                "OpenAI API key not found. Set OPENAI_API_KEY environment variable "
                "or add api_key to config.yaml"
            )
        
        try:
            self.client = OpenAI(api_key=self.api_key)
            self._initialized = True
            print(f"OpenAI provider initialized (model: {self.model})", file=sys.stderr)
        except Exception as e:
            raise RuntimeError(f"Failed to initialize OpenAI client: {e}")
    
    def generate(
        self,
        prompt: str,
        negative_prompt: Optional[str] = None,
        width: int = 512,
        height: int = 512,
        **kwargs
    ) -> Image.Image:
        """Generate image using DALL-E 3.
        
        Note: DALL-E 3 only supports specific sizes: 1024x1024, 1024x1792, 1792x1024
        Smaller sizes will be upscaled, then resized after generation.
        """
        if not self.is_initialized:
            self.initialize()
        
        # DALL-E 3 size constraints
        if width == height:
            dalle_size = "1024x1024"
        elif width > height:
            dalle_size = "1792x1024"
        else:
            dalle_size = "1024x1792"
        
        # Append negative prompt to main prompt
        full_prompt = prompt
        if negative_prompt:
            full_prompt += f" | Avoid: {negative_prompt}"
        
        try:
            print(f"Generating with DALL-E 3: {dalle_size}", file=sys.stderr)
            
            response = self.client.images.generate(
                model=self.model,
                prompt=full_prompt,
                size=dalle_size,
                quality=self.quality,
                n=1,
                response_format="b64_json"  # Get base64 for direct processing
            )
            
            # Decode base64 image
            image_data = base64.b64decode(response.data[0].b64_json)
            image = Image.open(io.BytesIO(image_data))
            
            # Resize to requested dimensions if different
            if image.size != (width, height):
                image = image.resize((width, height), Image.Resampling.LANCZOS)
            
            print(f"DALL-E generation complete: {width}x{height}", file=sys.stderr)
            return image
            
        except Exception as e:
            raise RuntimeError(f"DALL-E generation failed: {e}")
    
    def cleanup(self) -> None:
        """Clean up OpenAI client."""
        self.client = None
        self._initialized = False
    
    @property
    def name(self) -> str:
        return "openai"
