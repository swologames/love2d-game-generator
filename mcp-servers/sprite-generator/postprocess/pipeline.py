"""Post-processing pipeline for generated sprites."""

import sys
from typing import Optional, Tuple
from PIL import Image, ImageEnhance, ImageFilter

try:
    from rembg import remove
except ImportError:
    print("Warning: rembg not installed. Background removal disabled.", file=sys.stderr)
    remove = None


class PostProcessor:
    """Post-processes generated images for game use."""
    
    def __init__(self, config: dict):
        """Initialize post-processor.
        
        Args:
            config: Post-processing configuration dictionary
        """
        self.config = config
        self.remove_bg = config.get('remove_background', True)
        self.normalize_size = config.get('normalize_size', True)
        self.sharpen = config.get('sharpen', True)
        self.quantize_colors = config.get('color_quantize', False)
    
    def process(
        self,
        image: Image.Image,
        target_size: Optional[Tuple[int, int]] = None
    ) -> Image.Image:
        """Apply full post-processing pipeline.
        
        Args:
            image: Input PIL Image
            target_size: Target size (width, height) or None to keep original
            
        Returns:
            Processed PIL Image
        """
        print("Post-processing image...", file=sys.stderr)
        
        # Remove background first (works best on original)
        if self.remove_bg:
            image = self._remove_background(image)
        
        # Normalize size
        if self.normalize_size and target_size:
            image = self._resize_image(image, target_size)
        
        # Sharpen for crisp edges
        if self.sharpen:
            image = self._sharpen_image(image)
        
        # Quantize colors if requested
        if self.quantize_colors and isinstance(self.quantize_colors, int):
            image = self._quantize_colors(image, self.quantize_colors)
        
        print("Post-processing complete", file=sys.stderr)
        return image
    
    def _remove_background(self, image: Image.Image) -> Image.Image:
        """Remove background and ensure transparency.
        
        Args:
            image: Input image
            
        Returns:
            Image with transparent background
        """
        if remove is None:
            print("Warning: rembg not available, skipping background removal", file=sys.stderr)
            # Fallback: convert to RGBA if not already
            if image.mode != 'RGBA':
                image = image.convert('RGBA')
            return image
        
        try:
            print("Removing background...", file=sys.stderr)
            # rembg returns image with transparent background
            output = remove(image)
            
            # Ensure RGBA mode
            if output.mode != 'RGBA':
                output = output.convert('RGBA')
            
            return output
        except Exception as e:
            print(f"Warning: Background removal failed: {e}", file=sys.stderr)
            if image.mode != 'RGBA':
                image = image.convert('RGBA')
            return image
    
    def _resize_image(
        self,
        image: Image.Image,
        target_size: Tuple[int, int]
    ) -> Image.Image:
        """Resize image to target size with quality preservation.
        
        Args:
            image: Input image
            target_size: (width, height)
            
        Returns:
            Resized image
        """
        if image.size == target_size:
            return image
        
        print(f"Resizing from {image.size} to {target_size}", file=sys.stderr)
        
        # Use LANCZOS for high-quality downsampling
        return image.resize(target_size, Image.Resampling.LANCZOS)
    
    def _sharpen_image(self, image: Image.Image) -> Image.Image:
        """Sharpen image for crisp game sprites.
        
        Args:
            image: Input image
            
        Returns:
            Sharpened image
        """
        print("Sharpening edges...", file=sys.stderr)
        
        # Preserve alpha channel
        if image.mode == 'RGBA':
            # Split channels
            r, g, b, a = image.split()
            rgb = Image.merge('RGB', (r, g, b))
            
            # Sharpen RGB channels
            enhancer = ImageEnhance.Sharpness(rgb)
            rgb = enhancer.enhance(1.5)
            
            # Merge back with alpha
            r, g, b = rgb.split()
            return Image.merge('RGBA', (r, g, b, a))
        else:
            enhancer = ImageEnhance.Sharpness(image)
            return enhancer.enhance(1.5)
    
    def _quantize_colors(self, image: Image.Image, num_colors: int) -> Image.Image:
        """Reduce image to a limited color palette.
        
        Args:
            image: Input image
            num_colors: Number of colors in output palette
            
        Returns:
            Quantized image
        """
        print(f"Quantizing to {num_colors} colors...", file=sys.stderr)
        
        if image.mode == 'RGBA':
            # Preserve alpha by quantizing RGB separately
            r, g, b, a = image.split()
            rgb = Image.merge('RGB', (r, g, b))
            
            # Quantize RGB
            rgb = rgb.quantize(colors=num_colors)
            rgb = rgb.convert('RGB')
            
            # Merge back with alpha
            r, g, b = rgb.split()
            return Image.merge('RGBA', (r, g, b, a))
        else:
            return image.quantize(colors=num_colors).convert(image.mode)
    
    def create_thumbnail(
        self,
        image: Image.Image,
        max_size: int = 128
    ) -> Image.Image:
        """Create a thumbnail preview of the image.
        
        Args:
            image: Input image
            max_size: Maximum dimension for thumbnail
            
        Returns:
            Thumbnail image
        """
        thumb = image.copy()
        thumb.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
        return thumb
