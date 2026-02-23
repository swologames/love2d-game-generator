"""Prompt builder for sprite generation with GDD awareness."""

import os
import sys
import re
from typing import Dict, List, Optional


class PromptBuilder:
    """Builds optimized prompts for sprite generation."""
    
    # Style templates
    STYLE_TEMPLATES = {
        'pixel_art': 'pixel art, retro game sprite, clean pixels, {size} resolution',
        'hand_drawn': 'hand-drawn illustration, 2D game art, painterly style',
        '3d_rendered': '3D rendered, game asset, clean render, professional quality',
        'isometric': 'isometric perspective, game sprite, detailed illustration',
        'flat': 'flat design, minimalist game art, simple shapes, clean lines',
        'cartoon': 'cartoon style, colorful game character, expressive design'
    }
    
    # View angle templates
    VIEW_TEMPLATES = {
        'side_view': 'side view, profile perspective, 2D platformer style',
        'top_down': 'top-down view, overhead perspective, birds eye view',
        'isometric': 'isometric view, 3/4 perspective, angled view',
        '3_4': '3/4 view, three-quarter perspective',
        'front': 'front view, facing camera, straight on'
    }
    
    # Action/pose templates
    ACTION_TEMPLATES = {
        'idle': 'idle pose, standing still, neutral stance',
        'walk': 'walking animation pose, mid-step, natural movement',
        'run': 'running pose, dynamic movement, in motion',
        'jump': 'jumping pose, mid-air, legs bent',
        'attack': 'attacking pose, action stance, aggressive movement',
        'hurt': 'hurt pose, recoiling, taking damage',
        'death': 'defeated pose, falling, knocked down',
        'crouch': 'crouching pose, low stance',
        'climb': 'climbing pose, reaching upward'
    }
    
    def __init__(self, workspace_root: str):
        """Initialize prompt builder.
        
        Args:
            workspace_root: Root path of the workspace
        """
        self.workspace_root = workspace_root
        self._gdd_cache: Dict[str, Dict[str, str]] = {}
    
    def build_prompt(
        self,
        entity_type: str,
        action: str = 'idle',
        style: Optional[str] = None,
        view: str = 'side_view',
        game_name: Optional[str] = None,
        additional_details: Optional[str] = None,
        size_hint: str = 'game sprite'
    ) -> str:
        """Build a complete prompt for sprite generation.
        
        Args:
            entity_type: Type of entity (e.g., 'player', 'enemy', 'item')
            action: Action or pose (e.g., 'idle', 'walk', 'jump')
            style: Art style override (uses GDD if not specified)
            view: Camera view angle
            game_name: Name of the game (for GDD lookup)
            additional_details: Extra prompt details
            size_hint: Size description (e.g., '32x32 pixels', 'game sprite')
            
        Returns:
            Complete prompt string
        """
        parts = []
        
        # Get art style from GDD or use override
        if game_name and not style:
            gdd_info = self._read_gdd(game_name)
            style = gdd_info.get('art_style', 'pixel_art')
        elif not style:
            style = 'pixel_art'  # Default fallback
        
        # Add style
        style_template = self.STYLE_TEMPLATES.get(style, style)
        parts.append(style_template.format(size=size_hint))
        
        # Add view angle
        if view in self.VIEW_TEMPLATES:
            parts.append(self.VIEW_TEMPLATES[view])
        
        # Add entity type
        parts.append(f"{entity_type} character")
        
        # Add action/pose
        if action in self.ACTION_TEMPLATES:
            parts.append(self.ACTION_TEMPLATES[action])
        else:
            parts.append(f"{action} pose")
        
        # Add GDD color palette or theme if available
        if game_name:
            gdd_info = self._read_gdd(game_name)
            if 'color_palette' in gdd_info:
                parts.append(f"color palette: {gdd_info['color_palette']}")
            if 'theme' in gdd_info:
                parts.append(f"theme: {gdd_info['theme']}")
        
        # Add additional details
        if additional_details:
            parts.append(additional_details)
        
        # Add quality modifiers
        parts.append("transparent background")
        parts.append("game asset")
        parts.append("clean edges")
        parts.append("professional quality")
        
        return ", ".join(parts)
    
    def build_negative_prompt(self, base_negative: Optional[str] = None) -> str:
        """Build negative prompt for sprite generation.
        
        Args:
            base_negative: Base negative prompt from config
            
        Returns:
            Complete negative prompt string
        """
        negatives = [
            "watermark",
            "text",
            "signature",
            "blurry",
            "low quality",
            "artifacts",
            "photograph",
            "realistic",
            "3d render" if base_negative and 'pixel' in base_negative.lower() else None,
            "shadows" if base_negative and 'flat' in base_negative.lower() else None,
        ]
        
        # Filter out None values
        negatives = [n for n in negatives if n]
        
        if base_negative:
            negatives.insert(0, base_negative)
        
        return ", ".join(negatives)
    
    def _read_gdd(self, game_name: str) -> Dict[str, str]:
        """Read and parse relevant info from game's GAME_DESIGN.md.
        
        Args:
            game_name: Name of the game folder
            
        Returns:
            Dictionary with art_style, color_palette, theme, etc.
        """
        # Check cache first
        if game_name in self._gdd_cache:
            return self._gdd_cache[game_name]
        
        gdd_path = os.path.join(
            self.workspace_root,
            'games',
            game_name,
            'GAME_DESIGN.md'
        )
        
        info = {}
        
        if not os.path.exists(gdd_path):
            print(f"Warning: GDD not found for {game_name}", file=sys.stderr)
            self._gdd_cache[game_name] = info
            return info
        
        try:
            with open(gdd_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract art style
            art_match = re.search(
                r'(?:art\s+style|visual\s+style):\s*([^\n]+)',
                content,
                re.IGNORECASE
            )
            if art_match:
                style_text = art_match.group(1).strip().lower()
                # Map to our style templates
                if 'pixel' in style_text:
                    info['art_style'] = 'pixel_art'
                elif 'hand' in style_text or 'drawn' in style_text:
                    info['art_style'] = 'hand_drawn'
                elif 'isometric' in style_text:
                    info['art_style'] = 'isometric'
                elif 'flat' in style_text:
                    info['art_style'] = 'flat'
                elif 'cartoon' in style_text:
                    info['art_style'] = 'cartoon'
            
            # Extract color palette
            color_match = re.search(
                r'(?:color\s+palette|colors):\s*([^\n]+)',
                content,
                re.IGNORECASE
            )
            if color_match:
                info['color_palette'] = color_match.group(1).strip()
            
            # Extract theme
            theme_match = re.search(
                r'(?:theme|setting):\s*([^\n]+)',
                content,
                re.IGNORECASE
            )
            if theme_match:
                info['theme'] = theme_match.group(1).strip()
        
        except Exception as e:
            print(f"Warning: Failed to parse GDD for {game_name}: {e}", file=sys.stderr)
        
        # Cache the result
        self._gdd_cache[game_name] = info
        return info
