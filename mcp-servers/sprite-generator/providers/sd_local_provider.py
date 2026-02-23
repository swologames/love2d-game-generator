"""Local Stable Diffusion image generation provider."""

import sys
import os
from typing import Optional
from PIL import Image

try:
    import torch
    from diffusers import StableDiffusionPipeline, DPMSolverMultistepScheduler
except ImportError:
    print("Warning: torch/diffusers not installed. Install with: pip install torch diffusers", file=sys.stderr)
    torch = None
    StableDiffusionPipeline = None

from .base import ImageProvider


class LocalSDProvider(ImageProvider):
    """Local Stable Diffusion image generation provider."""
    
    def __init__(self, config: dict):
        super().__init__(config)
        self.pipeline = None
        self.model_path = config.get('model_path', 'runwayml/stable-diffusion-v1-5')
        self.device = config.get('device', 'cpu')
        self.torch_dtype_str = config.get('torch_dtype', 'float32')
        self.cache_dir = os.path.expanduser(config.get('cache_dir', '~/.cache/huggingface'))
        self.use_safetensors = config.get('use_safetensors', True)
    
    def initialize(self) -> None:
        """Initialize Stable Diffusion pipeline."""
        if torch is None or StableDiffusionPipeline is None:
            raise RuntimeError(
                "torch/diffusers not installed. Run: pip install torch diffusers transformers"
            )
        
        # Determine torch dtype
        if self.torch_dtype_str == 'float16':
            torch_dtype = torch.float16
        else:
            torch_dtype = torch.float32
        
        # Validate device
        if self.device == 'cuda' and not torch.cuda.is_available():
            print("Warning: CUDA not available, falling back to CPU", file=sys.stderr)
            self.device = 'cpu'
            torch_dtype = torch.float32
        elif self.device == 'mps' and not torch.backends.mps.is_available():
            print("Warning: MPS not available, falling back to CPU", file=sys.stderr)
            self.device = 'cpu'
            torch_dtype = torch.float32
        
        try:
            print(f"Loading Stable Diffusion model: {self.model_path}", file=sys.stderr)
            print(f"Device: {self.device}, dtype: {self.torch_dtype_str}", file=sys.stderr)
            
            # Load pipeline
            self.pipeline = StableDiffusionPipeline.from_pretrained(
                self.model_path,
                torch_dtype=torch_dtype,
                use_safetensors=self.use_safetensors,
                cache_dir=self.cache_dir
            )
            
            # Move to device
            self.pipeline = self.pipeline.to(self.device)
            
            # Use faster scheduler
            self.pipeline.scheduler = DPMSolverMultistepScheduler.from_config(
                self.pipeline.scheduler.config
            )
            
            # Enable memory optimizations
            if self.device == 'cuda':
                self.pipeline.enable_attention_slicing()
            elif self.device == 'mps':
                # MPS-specific optimizations
                self.pipeline.enable_attention_slicing()
            
            self._initialized = True
            print("Stable Diffusion pipeline ready", file=sys.stderr)
            
        except Exception as e:
            raise RuntimeError(f"Failed to initialize Stable Diffusion: {e}")
    
    def generate(
        self,
        prompt: str,
        negative_prompt: Optional[str] = None,
        width: int = 512,
        height: int = 512,
        **kwargs
    ) -> Image.Image:
        """Generate image using Stable Diffusion.
        
        Additional kwargs:
            num_inference_steps: Number of denoising steps (default: 30)
            guidance_scale: How closely to follow prompt (default: 7.5)
            seed: Random seed for reproducibility (optional)
        """
        if not self.is_initialized:
            self.initialize()
        
        # Extract SD-specific parameters
        num_steps = kwargs.get('num_inference_steps', kwargs.get('steps', 30))
        guidance = kwargs.get('guidance_scale', 7.5)
        seed = kwargs.get('seed')
        
        # Set generator for reproducibility if seed provided
        generator = None
        if seed is not None:
            generator = torch.Generator(device=self.device).manual_seed(seed)
        
        try:
            print(f"Generating with SD: {width}x{height}, steps: {num_steps}", file=sys.stderr)
            
            # Ensure dimensions are multiples of 8 (SD requirement)
            adj_width = (width // 8) * 8
            adj_height = (height // 8) * 8
            
            result = self.pipeline(
                prompt=prompt,
                negative_prompt=negative_prompt,
                width=adj_width,
                height=adj_height,
                num_inference_steps=num_steps,
                guidance_scale=guidance,
                generator=generator
            )
            
            image = result.images[0]
            
            # Resize to exact dimensions if adjusted
            if (adj_width, adj_height) != (width, height):
                image = image.resize((width, height), Image.Resampling.LANCZOS)
            
            print("SD generation complete", file=sys.stderr)
            return image
            
        except Exception as e:
            raise RuntimeError(f"Stable Diffusion generation failed: {e}")
    
    def cleanup(self) -> None:
        """Clean up pipeline and free memory."""
        if self.pipeline is not None:
            del self.pipeline
            self.pipeline = None
            
            if torch is not None and torch.cuda.is_available():
                torch.cuda.empty_cache()
        
        self._initialized = False
    
    @property
    def name(self) -> str:
        return "local_sd"
