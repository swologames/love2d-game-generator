#!/usr/bin/env python3
"""Quick test for local Stable Diffusion setup."""

import sys
from pathlib import Path

# Add server directory to path
sys.path.insert(0, str(Path(__file__).parent))

from config.loader import ConfigLoader
from providers.factory import ProviderFactory

def test_local_sd():
    print("Testing local Stable Diffusion setup...")
    print("-" * 50)
    
    # Load config
    config_path = Path(__file__).parent / "config.yaml"
    config_loader = ConfigLoader(str(config_path))
    config = config_loader.load()
    
    print("✓ Config loaded")
    
    # Get local_sd config
    sd_config = config_loader.get_provider_config("local_sd")
    if not sd_config:
        print("✗ No local_sd configuration found")
        return False
    
    print(f"✓ Local SD config found")
    print(f"  Model: {sd_config.get('model_path')}")
    print(f"  Device: {sd_config.get('device')}")
    print()
    
    # Try to create provider
    print("Initializing Stable Diffusion...")
    print("(First run will download ~4GB model - be patient!)")
    print()
    
    try:
        provider = ProviderFactory.create("local_sd", sd_config)
        print("✓ Provider initialized successfully!")
        print()
        
        # Try a simple generation
        print("Generating test image (512x512)...")
        print("Prompt: 'pixel art, game sprite, simple red circle, transparent background'")
        print()
        
        image = provider.generate(
            prompt="pixel art, game sprite, simple red circle, transparent background, clean",
            negative_prompt="blurry, text, watermark",
            width=256,  # Smaller for faster test
            height=256,
            num_inference_steps=20  # Fewer steps for test
        )
        
        print("✓ Image generated successfully!")
        print(f"  Size: {image.size}")
        print(f"  Mode: {image.mode}")
        print()
        
        # Save test image
        output_path = Path(__file__).parent / "test_output.png"
        image.save(output_path)
        print(f"✓ Test image saved to: {output_path}")
        print()
        
        provider.cleanup()
        
        print("=" * 50)
        print("SUCCESS! Local Stable Diffusion is working!")
        print("=" * 50)
        return True
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_local_sd()
    sys.exit(0 if success else 1)
