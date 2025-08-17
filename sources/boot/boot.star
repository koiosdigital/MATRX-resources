"""
MATRX Boot Animation - Simplified version with shooting fireworks
"""

load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")
load("random.star", "random")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

def main(config):
    """Main entry point for the boot animation"""
    width = int(config.get("width", DEFAULT_WIDTH))
    height = int(config.get("height", DEFAULT_HEIGHT))
    
    frames = create_boot_animation(width, height)
    
    return render.Root(
        delay = 100,  # 100ms per frame for smooth animation
        child = render.Animation(children = frames),
    )

def create_boot_animation(width, height):
    """Creates MATRX boot animation with typeahead text and fireworks"""
    frames = []
    
    # Two phases: typeahead (8 frames) + fireworks (8 frames)
    total_frames = 16
    
    # Choose font based on screen size
    font_name = "tom-thumb" if width < 32 else "6x13"
    
    for frame_idx in range(total_frames):
        elements = []
        
        # Black background
        elements.append(
            render.Box(
                width = width,
                height = height,
                color = "#000000",
            )
        )
        
        # Show typeahead text for first 8 frames, then full text
        if frame_idx < 8:
            elements.extend(create_typeahead_text(width, height, frame_idx, font_name))
        else:
            elements.extend(create_full_text(width, height, font_name))
        
        # Start fireworks from frame 3 onwards (when "MAT" appears)
        if frame_idx >= 3:
            firework_frame = frame_idx - 3
            elements.extend(create_old_fireworks(width, height, firework_frame))
        
        frame = render.Stack(children = elements)
        frames.append(frame)
    
    return frames

def create_typeahead_text(width, height, frame_idx, font_name):
    """Create typeahead effect for MATRX text"""
    elements = []
    
    # Build text progressively
    matrx_text = "MATRX"
    if frame_idx < 5:
        current_text = matrx_text[:frame_idx + 1]
    else:
        current_text = matrx_text
    
    # Calculate accurate text dimensions based on font
    if font_name == "tom-thumb":
        char_width = 4  # tom-thumb is approximately 4px wide per char
        text_height = 5  # tom-thumb is 5px tall
    else:
        char_width = 6  # 6x13 is 6px wide per char
        text_height = 13  # 6x13 is 13px tall
    
    text_width = len(current_text) * char_width
    
    # Center both horizontally and vertically
    text_x = max(0, math.floor((width - text_width) / 2))
    text_y = max(0, math.floor((height - text_height) / 2))
    
    # Show current text in white
    elements.append(
        render.Padding(
            pad = (text_x, text_y, 0, 0),
            child = render.Text(
                content = current_text,
                color = "#ffffff",
                font = font_name
            ),
        )
    )
    
    return elements

def create_full_text(width, height, font_name):
    """Create full MATRX text"""
    elements = []
    
    # Calculate accurate text dimensions based on font
    text_content = "MATRX"
    if font_name == "tom-thumb":
        char_width = 4  # tom-thumb is approximately 4px wide per char
        text_height = 5  # tom-thumb is 5px tall
    else:
        char_width = 6  # 6x13 is 6px wide per char
        text_height = 13  # 6x13 is 13px tall
    
    text_width = len(text_content) * char_width
    
    # Center both horizontally and vertically
    text_x = max(0, math.floor((width - text_width) / 2))
    text_y = max(0, math.floor((height - text_height) / 2))
    
    # Show full MATRX text in white
    elements.append(
        render.Padding(
            pad = (text_x, text_y, 0, 0),
            child = render.Text(
                content = text_content,
                color = "#ffffff",
                font = font_name
            ),
        )
    )
    
    return elements

def create_old_fireworks(width, height, frame_idx):
    """Create old-style rainbow firework explosions"""
    elements = []
    
    # Multiple firework explosion centers
    firework_centers = [
        (width // 4, height // 3),
        (3 * width // 4, height // 4),
        (width // 2, 3 * height // 4),
        (width // 6, 2 * height // 3),
        (5 * width // 6, height // 2)
    ]
    
    for fw_idx, (center_x, center_y) in enumerate(firework_centers):
        # Stagger firework timing
        firework_frame = (frame_idx - fw_idx) % 10
        
        if firework_frame >= 0 and firework_frame < 8:
            # Create expanding circle of sparkles
            radius = firework_frame + 1
            num_sparkles = 8 + firework_frame * 2  # More sparkles as it expands
            
            for i in range(num_sparkles):
                angle = (i * 360 / num_sparkles) * math.pi / 180
                
                # Calculate sparkle position
                spark_x = int(center_x + radius * math.cos(angle))
                spark_y = int(center_y + radius * math.sin(angle))
                
                # Rainbow colors based on angle
                hue_step = i * 6 // num_sparkles  # 0-5 for 6 colors
                if hue_step == 0:
                    color = "#ff0000"  # Red
                elif hue_step == 1:
                    color = "#ff8800"  # Orange  
                elif hue_step == 2:
                    color = "#ffff00"  # Yellow
                elif hue_step == 3:
                    color = "#00ff00"  # Green
                elif hue_step == 4:
                    color = "#0088ff"  # Blue
                else:
                    color = "#8800ff"  # Purple
                
                # Only draw sparkles within screen bounds
                if spark_x >= 0 and spark_x < width and spark_y >= 0 and spark_y < height:
                    # Sparkle gets smaller as firework ages
                    sparkle_size = max(1, 3 - firework_frame // 3)
                    
                    elements.append(
                        render.Padding(
                            pad = (spark_x, spark_y, 0, 0),
                            child = render.Box(
                                width = sparkle_size,
                                height = sparkle_size,
                                color = color,
                            ),
                        )
                    )
    
    return elements

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "width",
                name = "Display Width",
                desc = "Width of the display in pixels",
                icon = "ruler",
                default = DEFAULT_WIDTH,
            ),
            schema.Text(
                id = "height", 
                name = "Display Height",
                desc = "Height of the display in pixels",
                icon = "ruler",
                default = DEFAULT_HEIGHT,
            ),
        ],
    )
