#!/usr/bin/env python3
"""
Generate PNG logos for Posta app
Creates high-quality PNG files in various sizes
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_stylish_p_logo(size=512):
    """Create a stylish P logo at specified size"""
    # Create white background
    img = Image.new('RGB', (size, size), 'white')
    draw = ImageDraw.Draw(img)
    
    # Calculate proportions based on size
    margin = size // 8
    p_width = size - 2 * margin
    p_height = size - 2 * margin
    
    # P coordinates
    x1 = margin
    y1 = margin
    x2 = x1 + p_width
    y2 = y1 + p_height
    
    # Draw main P shape
    p_points = [
        (x1, y1),                    # Top left
        (x1, y2),                    # Bottom left
        (x1 + p_width//2, y2),      # Bottom middle
        (x1 + p_width, y2 - p_height//3),  # Bottom right
        (x1 + p_width, y1 + p_height//3),  # Top right
        (x1 + p_width//2, y1),      # Top middle
    ]
    draw.polygon(p_points, fill='black')
    
    # Open space in P (represents openness)
    open_size = p_width // 4
    open_x = x1 + p_width//3
    open_y = y1 + p_height//4
    draw.rectangle([open_x, open_y, open_x + open_size, open_y + open_size], fill='white')
    
    # Stylish accent line
    line_start_x = x1 + p_width
    line_start_y = y1 + p_height//2
    line_end_x = x2 + margin//2
    line_end_y = y1 + p_height//3
    draw.line([(line_start_x, line_start_y), (line_end_x, line_end_y)], fill='black', width=max(3, size//100))
    
    # Modern dots representing community
    dot_positions = [
        (line_end_x - margin//4, line_end_y - margin//4),
        (line_end_x, line_end_y),
        (line_end_x - margin//6, line_end_y + margin//4)
    ]
    
    for i, (x, y) in enumerate(dot_positions):
        dot_size = max(3, size//100) + i
        draw.ellipse([x-dot_size, y-dot_size, x+dot_size, y+dot_size], fill='black')
    
    # Corner accents
    corner_size = max(8, size//50)
    corners = [(x1, y1), (x2, y1), (x1, y2), (x2, y2)]
    for x, y in corners:
        draw.ellipse([x-corner_size, y-corner_size, x+corner_size, y+corner_size], fill='black')
    
    return img

def create_text_logo(size=400):
    """Create a text-based logo"""
    img = Image.new('RGB', (size, size//3), 'white')
    draw = ImageDraw.Draw(img)
    
    # Try to use a modern font, fallback to default if not available
    try:
        # Try to use a bold, modern font
        font_size = size // 8
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        try:
            font = ImageFont.truetype("arial.ttf", font_size)
        except:
            font = ImageFont.load_default()
    
    text = "POSTA"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size//3 - text_height) // 2
    
    draw.text((x, y), text, fill='black', font=font)
    
    # Underline
    line_y = y + text_height + 10
    draw.line([(x, line_y), (x + text_width, line_y)], fill='black', width=max(2, size//200))
    
    return img

def main():
    """Generate all logo variants"""
    print("Generating Posta PNG logos...")
    
    # Create output directory
    os.makedirs('assets/icons', exist_ok=True)
    os.makedirs('assets/logos', exist_ok=True)
    
    # Generate stylish P logo in various sizes
    sizes = [16, 32, 48, 64, 72, 96, 128, 144, 192, 256, 512]
    
    print("Creating stylish P logos...")
    for size in sizes:
        logo = create_stylish_p_logo(size)
        filename = f'assets/icons/logo-p-stylish-{size}.png'
        logo.save(filename, 'PNG', optimize=True)
        print(f"  Created {filename}")
    
    # Generate text logo
    print("Creating text logo...")
    text_logo = create_text_logo(512)
    text_logo.save('assets/logos/logo-text-512.png', 'PNG', optimize=True)
    
    # Generate app icon sizes
    print("Creating app icon sizes...")
    app_icon_sizes = {
        'ios': [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024],
        'android': [36, 48, 72, 96, 144, 192, 512],
        'web': [16, 32, 192, 512]
    }
    
    for platform, platform_sizes in app_icon_sizes.items():
        for size in platform_sizes:
            logo = create_stylish_p_logo(size)
            filename = f'assets/icons/{platform}-{size}.png'
            logo.save(filename, 'PNG', optimize=True)
            print(f"  Created {filename}")
    
    print("\nLogo generation complete!")
    print("Files saved to assets/icons/ and assets/logos/")

if __name__ == "__main__":
    main() 