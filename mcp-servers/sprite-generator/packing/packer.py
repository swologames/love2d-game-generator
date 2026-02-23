"""Spritesheet packing using shelf algorithm."""

import sys
from typing import List, Tuple, Dict
from PIL import Image
from dataclasses import dataclass


@dataclass
class SpriteRect:
    """Represents a sprite rectangle in a spritesheet."""
    name: str
    image: Image.Image
    x: int = 0
    y: int = 0
    width: int = 0
    height: int = 0


class SheetPacker:
    """Packs multiple sprites into a single spritesheet."""
    
    def __init__(self, padding: int = 4, power_of_two: bool = True):
        """Initialize sheet packer.
        
        Args:
            padding: Pixels of padding between sprites
            power_of_two: Force dimensions to be power of 2 (GPU optimization)
        """
        self.padding = padding
        self.power_of_two = power_of_two
    
    def pack(
        self,
        sprites: Dict[str, Image.Image],
        max_size: int = 4096
    ) -> Tuple[Image.Image, List[SpriteRect]]:
        """Pack sprites into a single spritesheet.
        
        Args:
            sprites: Dictionary of {name: PIL Image}
            max_size: Maximum dimension for the output sheet
            
        Returns:
            Tuple of (packed_image, list of SpriteRect with positions)
            
        Raises:
            ValueError: If sprites don't fit in max_size
        """
        if not sprites:
            raise ValueError("No sprites to pack")
        
        print(f"Packing {len(sprites)} sprites...", file=sys.stderr)
        
        # Create sprite rectangles
        rects = []
        for name, image in sprites.items():
            rect = SpriteRect(
                name=name,
                image=image,
                width=image.width,
                height=image.height
            )
            rects.append(rect)
        
        # Sort by height (descending) for better packing
        rects.sort(key=lambda r: r.height, reverse=True)
        
        # Pack using shelf algorithm
        packed_rects = self._shelf_pack(rects, max_size)
        
        # Calculate final sheet dimensions
        max_x = max(r.x + r.width for r in packed_rects)
        max_y = max(r.y + r.height for r in packed_rects)
        
        # Round up to power of 2 if requested
        if self.power_of_two:
            sheet_width = self._next_power_of_2(max_x)
            sheet_height = self._next_power_of_2(max_y)
        else:
            sheet_width = max_x
            sheet_height = max_y
        
        print(f"Sheet size: {sheet_width}x{sheet_height}", file=sys.stderr)
        
        # Create the final spritesheet
        sheet = Image.new('RGBA', (sheet_width, sheet_height), (0, 0, 0, 0))
        
        # Paste sprites onto sheet
        for rect in packed_rects:
            sheet.paste(rect.image, (rect.x, rect.y), rect.image)
        
        return sheet, packed_rects
    
    def _shelf_pack(
        self,
        rects: List[SpriteRect],
        max_size: int
    ) -> List[SpriteRect]:
        """Pack rectangles using shelf algorithm.
        
        Args:
            rects: List of sprite rectangles to pack
            max_size: Maximum dimension
            
        Returns:
            List of rectangles with x, y positions set
        """
        shelves = []
        current_shelf_y = self.padding
        current_shelf_height = 0
        current_x = self.padding
        
        for rect in rects:
            rect_width = rect.width + self.padding
            rect_height = rect.height + self.padding
            
            # Check if sprite fits on current shelf
            if current_x + rect_width > max_size:
                # Start new shelf
                current_shelf_y += current_shelf_height
                current_x = self.padding
                current_shelf_height = 0
            
            # Check if we exceed vertical space
            if current_shelf_y + rect_height > max_size:
                raise ValueError(
                    f"Sprites don't fit in {max_size}x{max_size} sheet. "
                    f"Try reducing sprite count or increasing max_size."
                )
            
            # Place sprite
            rect.x = current_x
            rect.y = current_shelf_y
            
            # Update shelf tracking
            current_x += rect_width
            current_shelf_height = max(current_shelf_height, rect_height)
        
        return rects
    
    @staticmethod
    def _next_power_of_2(n: int) -> int:
        """Get the next power of 2 >= n."""
        power = 1
        while power < n:
            power *= 2
        return power
