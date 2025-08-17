#!/usr/bin/env python3
"""
Simple PNG logo generator for Posta
Creates the speech bubble logo as PNG files
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("PIL/Pillow not available. Install with: pip install Pillow")

def create_speech_bubble_logo(size=512):
    """Create speech bubble logo with Posta text"""
    if not PIL_AVAILABLE:
        print("Cannot create logo - PIL not available")
        return None
    
    # Create white background
    img = Image.new('RGB', (size, size), 'white')
    draw = ImageDraw.Draw(img)
    
    # Calculate proportions
    margin = size // 8
    bubble_size = size - 2 * margin
    
    # Speech bubble coordinates
    x1 = margin
    y1 = margin
    x2 = x1 + bubble_size
    y2 = y1 + bubble_size
    
    # Draw speech bubble (rounded rectangle)
    draw.rounded_rectangle([x1, y1, x2, y2], radius=size//20, fill='white', outline='black', width=max(3, size//100))
    
    # Draw speech bubble tail
    tail_width = size // 20
    tail_height = size // 15
    tail_x = x1 + bubble_size // 4
    tail_y = y2
    
    tail_points = [
        (tail_x, tail_y),
        (tail_x + tail_width, tail_y),
        (tail_x + tail_width//2, tail_y + tail_height)
    ]
    draw.polygon(tail_points, fill='black')
    
    # Center dot in bubble
    dot_size = size // 20
    dot_x = (x1 + x2) // 2
    dot_y = (y1 + y2) // 2
    draw.ellipse([dot_x-dot_size, dot_y-dot_size, dot_x+dot_size, dot_y+dot_size], fill='black')
    
    # Add "POSTA" text below bubble
    try:
        # Try to use a bold font
        font_size = size // 12
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
    
    text_x = (size - text_width) // 2
    text_y = y2 + tail_height + size // 20
    
    draw.text((text_x, text_y), text, fill='black', font=font)
    
    return img

def main():
    """Generate logo files"""
    if not PIL_AVAILABLE:
        print("Please install Pillow: pip install Pillow")
        return
    
    print("Creating Posta logo files...")
    
    # Create output directory
    import os
    os.makedirs('assets', exist_ok=True)
    
    # Generate main logo
    sizes = [64, 128, 256, 512]
    for size in sizes:
        logo = create_speech_bubble_logo(size)
        if logo:
            filename = f'assets/logo-{size}.png'
            logo.save(filename, 'PNG', optimize=True)
            print(f"Created {filename}")
    
    # Generate app icon sizes
    app_sizes = {
        'ios': [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024],
        'android': [36, 48, 72, 96, 144, 192, 512]
    }
    
    for platform, platform_sizes in app_sizes.items():
        for size in platform_sizes:
            logo = create_speech_bubble_logo(size)
            if logo:
                filename = f'assets/{platform}-{size}.png'
                logo.save(filename, 'PNG', optimize=True)
                print(f"Created {filename}")
    
    print("\nLogo generation complete!")

if __name__ == "__main__":
    main() 