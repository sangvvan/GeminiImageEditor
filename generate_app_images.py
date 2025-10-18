#!/usr/bin/env python3
"""
MakeIt App Image Generator
Creates app icons, launch screen, and banner images for the MakeIt iOS app
"""

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon(size):
    """Create app icon with MakeIt branding"""
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Define colors - modern gradient theme
    colors = [
        (99, 102, 241),   # Indigo
        (139, 92, 246),   # Purple
        (168, 85, 247),   # Violet
        (236, 72, 153),   # Pink
    ]
    
    # Create gradient background
    for i in range(size):
        ratio = i / size
        color_idx = int(ratio * (len(colors) - 1))
        next_color_idx = min(color_idx + 1, len(colors) - 1)
        
        # Interpolate between colors
        r = int(colors[color_idx][0] + (colors[next_color_idx][0] - colors[color_idx][0]) * (ratio * (len(colors) - 1) - color_idx))
        g = int(colors[color_idx][1] + (colors[next_color_idx][1] - colors[color_idx][1]) * (ratio * (len(colors) - 1) - color_idx))
        b = int(colors[color_idx][2] + (colors[next_color_idx][2] - colors[color_idx][2]) * (ratio * (len(colors) - 1) - color_idx))
        
        draw.line([(0, i), (size, i)], fill=(r, g, b, 255))
    
    # Add rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = size // 6
    mask_draw.rounded_rectangle([0, 0, size, size], corner_radius, fill=255)
    
    # Apply mask
    img.putalpha(mask)
    
    # Add "M" logo in the center
    font_size = max(size // 3, 12)  # Ensure minimum font size
    
    # Try different font paths
    font = None
    font_paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Times.ttc"
    ]
    
    for font_path in font_paths:
        try:
            font = ImageFont.truetype(font_path, font_size)
            break
        except:
            continue
    
    if font is None:
        # Use default font if no system fonts work
        font = ImageFont.load_default()
    
    # Get text dimensions safely
    try:
        bbox = draw.textbbox((0, 0), "M", font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
    except:
        # Fallback dimensions if textbbox fails
        text_width = font_size
        text_height = font_size
    
    # Center the text
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 2  # Slight adjustment for better centering
    
    # Add white text with shadow
    try:
        draw.text((x + 2, y + 2), "M", font=font, fill=(255, 255, 255, 100))  # Shadow
        draw.text((x, y), "M", font=font, fill=(255, 255, 255, 255))  # Main text
    except:
        # If text rendering fails, just draw a simple shape
        draw.ellipse([x, y, x + text_width, y + text_height], fill=(255, 255, 255, 255))
    
    return img

def create_launch_screen(width=1125, height=2436):
    """Create launch screen image"""
    img = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background
    for i in range(height):
        ratio = i / height
        # Light blue to white gradient
        r = int(240 + (255 - 240) * ratio)
        g = int(248 + (255 - 248) * ratio)
        b = int(255)
        draw.line([(0, i), (width, i)], fill=(r, g, b))
    
    # Add MakeIt logo in center
    logo_size = min(width, height) // 4
    logo = create_app_icon(logo_size)
    
    # Paste logo in center
    x = (width - logo_size) // 2
    y = (height - logo_size) // 2
    img.paste(logo, (x, y), logo)
    
    # Add app name below logo
    font_size = 48
    font = None
    font_paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Times.ttc"
    ]
    
    for font_path in font_paths:
        try:
            font = ImageFont.truetype(font_path, font_size)
            break
        except:
            continue
    
    if font is None:
        font = ImageFont.load_default()
    
    app_name = "MakeIt"
    try:
        bbox = draw.textbbox((0, 0), app_name, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
    except:
        text_width = len(app_name) * 30
        text_height = 50
    
    text_x = (width - text_width) // 2
    text_y = y + logo_size + 30
    
    draw.text((text_x, text_y), app_name, font=font, fill=(99, 102, 241))
    
    # Add tagline
    tagline_font_size = 24
    tagline_font = None
    
    for font_path in font_paths:
        try:
            tagline_font = ImageFont.truetype(font_path, tagline_font_size)
            break
        except:
            continue
    
    if tagline_font is None:
        tagline_font = ImageFont.load_default()
    
    tagline = "AI-Powered Content Creation"
    try:
        tagline_bbox = draw.textbbox((0, 0), tagline, font=tagline_font)
        tagline_width = tagline_bbox[2] - tagline_bbox[0]
    except:
        tagline_width = len(tagline) * 15
    
    tagline_x = (width - tagline_width) // 2
    tagline_y = text_y + text_height + 20
    
    draw.text((tagline_x, tagline_y), tagline, font=tagline_font, fill=(156, 163, 175))
    
    return img

def create_banner_image(width=400, height=200, title="AI Generation", subtitle="Create amazing content"):
    """Create banner image for carousel"""
    img = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background
    colors = [
        (99, 102, 241),   # Indigo
        (139, 92, 246),   # Purple
        (168, 85, 247),   # Violet
    ]
    
    for i in range(height):
        ratio = i / height
        color_idx = int(ratio * (len(colors) - 1))
        next_color_idx = min(color_idx + 1, len(colors) - 1)
        
        r = int(colors[color_idx][0] + (colors[next_color_idx][0] - colors[color_idx][0]) * (ratio * (len(colors) - 1) - color_idx))
        g = int(colors[color_idx][1] + (colors[next_color_idx][1] - colors[color_idx][1]) * (ratio * (len(colors) - 1) - color_idx))
        b = int(colors[color_idx][2] + (colors[next_color_idx][2] - colors[color_idx][2]) * (ratio * (len(colors) - 1) - color_idx))
        
        draw.line([(0, i), (width, i)], fill=(r, g, b))
    
    # Add text
    font_paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Times.ttc"
    ]
    
    title_font = None
    for font_path in font_paths:
        try:
            title_font = ImageFont.truetype(font_path, 32)
            break
        except:
            continue
    
    if title_font is None:
        title_font = ImageFont.load_default()
    
    subtitle_font = None
    for font_path in font_paths:
        try:
            subtitle_font = ImageFont.truetype(font_path, 16)
            break
        except:
            continue
    
    if subtitle_font is None:
        subtitle_font = ImageFont.load_default()
    
    # Title
    try:
        title_bbox = draw.textbbox((0, 0), title, font=title_font)
        title_width = title_bbox[2] - title_bbox[0]
    except:
        title_width = len(title) * 20
    
    title_x = (width - title_width) // 2
    title_y = height // 2 - 20
    
    draw.text((title_x, title_y), title, font=title_font, fill=(255, 255, 255))
    
    # Subtitle
    try:
        subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
        subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    except:
        subtitle_width = len(subtitle) * 10
    
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = title_y + 40
    
    draw.text((subtitle_x, subtitle_y), subtitle, font=subtitle_font, fill=(255, 255, 255, 200))
    
    return img

def main():
    """Generate all app images"""
    print("🎨 Generating MakeIt App Images...")
    
    # Create output directory
    output_dir = "AppImages"
    os.makedirs(output_dir, exist_ok=True)
    
    # App icon sizes for iOS
    icon_sizes = [
        20, 29, 40, 58, 60, 76, 80, 87, 114, 120, 152, 167, 180, 1024
    ]
    
    print("📱 Creating app icons...")
    for size in icon_sizes:
        icon = create_app_icon(size)
        icon.save(f"{output_dir}/AppIcon-{size}x{size}.png")
        print(f"  ✅ Created {size}x{size} icon")
    
    # Create AppIcon.appiconset directory structure
    appiconset_dir = f"{output_dir}/AppIcon.appiconset"
    os.makedirs(appiconset_dir, exist_ok=True)
    
    # Copy icons to AppIcon.appiconset with proper names
    icon_mappings = {
        20: ["AppIcon-20x20@2x.png", "AppIcon-20x20@3x.png"],
        29: ["AppIcon-29x29.png", "AppIcon-29x29@2x.png", "AppIcon-29x29@3x.png"],
        40: ["AppIcon-40x40@2x.png", "AppIcon-40x40@3x.png"],
        60: ["AppIcon-60x60@2x.png", "AppIcon-60x60@3x.png"],
        76: ["AppIcon-76x76.png", "AppIcon-76x76@2x.png"],
        83.5: ["AppIcon-83.5x83.5@2x.png"],
        1024: ["AppIcon-1024x1024.png"]
    }
    
    for base_size, filenames in icon_mappings.items():
        for filename in filenames:
            if base_size == 83.5:
                source_size = 167
            elif "@2x" in filename:
                source_size = int(base_size * 2)
            elif "@3x" in filename:
                source_size = int(base_size * 3)
            else:
                source_size = int(base_size)
            
            if source_size in icon_sizes:
                icon = create_app_icon(source_size)
                icon.save(f"{appiconset_dir}/{filename}")
                print(f"  ✅ Created {filename}")
    
    # Create Contents.json for AppIcon.appiconset
    contents_json = '''{
  "images" : [
    {
      "filename" : "AppIcon-20x20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "AppIcon-20x20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "AppIcon-29x29.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-29x29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-29x29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-40x40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "AppIcon-40x40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "AppIcon-60x60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "AppIcon-60x60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "AppIcon-76x76.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "AppIcon-76x76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "AppIcon-83.5x83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "AppIcon-1024x1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}'''
    
    with open(f"{appiconset_dir}/Contents.json", "w") as f:
        f.write(contents_json)
    
    print("📱 Creating launch screen...")
    launch_screen = create_launch_screen()
    launch_screen.save(f"{output_dir}/LaunchScreen.png")
    print("  ✅ Created launch screen")
    
    print("🎨 Creating banner images...")
    banners = [
        ("Text to Video", "Create videos from text prompts"),
        ("AI Photo Enhancement", "Transform your photos with AI"),
        ("Face Swap", "Swap faces in photos and videos"),
        ("Image Generation", "Generate images from descriptions")
    ]
    
    for i, (title, subtitle) in enumerate(banners):
        banner = create_banner_image(title=title, subtitle=subtitle)
        banner.save(f"{output_dir}/banner_{i+1}.png")
        print(f"  ✅ Created banner: {title}")
    
    print("\n🎉 All images generated successfully!")
    print(f"📁 Images saved to: {output_dir}/")
    print("\n📋 Next steps:")
    print("1. Copy AppIcon.appiconset to GeminiImageEditor/Assets.xcassets/")
    print("2. Add banner images to your carousel")
    print("3. Use LaunchScreen.png as your launch screen image")

if __name__ == "__main__":
    main()
