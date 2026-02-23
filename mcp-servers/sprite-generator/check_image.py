#!/usr/bin/env python3
"""Check if an image is all black."""

from PIL import Image
import sys

img_path = "/Users/diegopinate/Documents/Love2DAI/mcp-servers/sprite-generator/test_output.png"
img = Image.open(img_path)

# Convert to RGB if needed
if img.mode != 'RGB':
    img = img.convert('RGB')

# Get pixel data
pixels = list(img.getdata())

# Count black pixels (0,0,0)
black_count = sum(1 for p in pixels if p == (0, 0, 0))
total_pixels = len(pixels)

# Get some sample pixels
samples = pixels[::1000]  # Every 1000th pixel

print(f"Image size: {img.size}")
print(f"Total pixels: {total_pixels}")
print(f"Black pixels: {black_count} ({100*black_count/total_pixels:.1f}%)")
print(f"Sample pixels: {samples[:10]}")

# Get min and max values
r_vals = [p[0] for p in pixels]
g_vals = [p[1] for p in pixels]
b_vals = [p[2] for p in pixels]

print(f"\nR channel: min={min(r_vals)}, max={max(r_vals)}")
print(f"G channel: min={min(g_vals)}, max={max(g_vals)}")
print(f"B channel: min={min(b_vals)}, max={max(b_vals)}")

if black_count == total_pixels:
    print("\n❌ IMAGE IS COMPLETELY BLACK!")
else:
    print(f"\n✓ Image has {total_pixels - black_count} non-black pixels")
