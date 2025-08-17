load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

def to_hex_string(value):
    """Convert integer to 2-digit hex string"""
    if value < 0:
        value = 0
    elif value > 255:
        value = 255
    
    hex_chars = "0123456789abcdef"
    high = math.floor(value / 16)
    low = value % 16
    return hex_chars[high] + hex_chars[low]

def main(config):
    width = int(config.str("width", DEFAULT_WIDTH))
    height = int(config.str("height", DEFAULT_HEIGHT))
    
    # Create keygen animation frames
    keygen_frames = create_keygen_animation(width, height)
    
    return render.Root(
        delay = 100,  # 100ms per frame for smooth spinner
        child = render.Animation(
            children = keygen_frames,
        ),
    )

def create_keygen_animation(width, height):
    """Creates keygen animation with key icon, spinner, and text"""
    frames = []
    
    # Number of frames for spinner rotation
    num_frames = 24  # 24 frames for smooth 360° rotation
    
    # Determine layout based on screen aspect ratio
    is_square = abs(width - height) <= 4  # Consider nearly square as square
    
    for frame_idx in range(num_frames):
        elements = []
        
        # Background
        elements.append(
            render.Box(
                width = width,
                height = height,
                color = "#000000",  # Black background
            )
        )
        
        if is_square:
            # Square screen: vertical layout (icon on top of text)
            elements.extend(create_vertical_layout(width, height, frame_idx))
        else:
            # Rectangle screen: horizontal layout (icon to left of text)
            elements.extend(create_horizontal_layout(width, height, frame_idx))
        
        frame = render.Stack(children = elements)
        frames.append(frame)
    
    return frames

def create_vertical_layout(width, height, frame_idx):
    """Create vertical layout for square screens"""
    elements = []
    
    # Choose font based on screen size
    use_small_font = width < 32 or height < 32
    font_name = "tom-thumb" if use_small_font else "6x13"
    text_height = 5 if use_small_font else 13  # tom-thumb is ~5px tall
    char_width = 4 if use_small_font else 6    # tom-thumb is ~4px wide
    
    # Calculate positions for vertical layout
    icon_size = 16
    spacing = 3 if use_small_font else 4
    
    total_height = icon_size + spacing + text_height
    start_y = math.floor((height - total_height) / 2)
    
    # Icon position (centered horizontally, top of layout)
    icon_x = math.floor((width - icon_size) / 2)
    icon_y = start_y
    
    # Text position (centered horizontally, bottom of layout)
    text_content = "keygen"
    text_width = len(text_content) * char_width
    text_x = math.floor((width - text_width) / 2)
    text_y = start_y + icon_size + spacing
    
    # Add spinner (without key)
    elements.extend(create_spinner(icon_x, icon_y, icon_size, frame_idx))
    
    # Add text
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

def create_horizontal_layout(width, height, frame_idx):
    """Create horizontal layout for rectangle screens"""
    elements = []
    
    # Choose font based on screen size
    use_small_font = width < 32 or height < 32
    font_name = "tom-thumb" if use_small_font else "6x13"
    text_height = 5 if use_small_font else 13  # tom-thumb is ~5px tall
    char_width = 4 if use_small_font else 6    # tom-thumb is ~4px wide
    
    # Calculate positions for horizontal layout
    icon_size = 16
    spacing = 4 if use_small_font else 6
    
    text_content = "keygen"
    text_width = len(text_content) * char_width
    
    total_width = icon_size + spacing + text_width
    start_x = math.floor((width - total_width) / 2)
    
    # Icon position (left side, vertically centered)
    icon_x = start_x
    icon_y = math.floor((height - icon_size) / 2)
    
    # Text position (right side, vertically centered)
    text_x = start_x + icon_size + spacing
    text_y = math.floor((height - text_height) / 2)
    
    # Add spinner (without key)
    elements.extend(create_spinner(icon_x, icon_y, icon_size, frame_idx))
    
    # Add text
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

def create_spinner(x, y, size, frame_idx):
    """Create rotating spinner dots around the key"""
    elements = []
    
    # Number of spinner dots - more dots for smoother effect
    num_dots = 12
    
    # Bigger radius for more prominent spinner
    radius = math.floor(size * 0.9)  # Increased from 0.7 to 0.9
    center_x = x + size // 2
    center_y = y + size // 2
    
    # Current rotation angle - slower rotation for better visibility
    rotation = (frame_idx * 12) % 360  # 12 degrees per frame (was 15)
    
    for i in range(num_dots):
        # Calculate angle for this dot
        angle = (i * 30 + rotation) % 360  # 30 degrees between dots (360/12)
        
        # Convert to radians
        angle_rad = angle * math.pi / 180
        
        # Calculate position with full radius
        dot_x = int(center_x + radius * math.cos(angle_rad) / 1.8)  # Reduced divisor for bigger radius
        dot_y = int(center_y + radius * math.sin(angle_rad) / 1.8)
        
        # Enhanced fade effect - leading dots are brighter
        fade_factor = (num_dots - i) / num_dots
        brightness = int(80 + 175 * fade_factor)  # Range from 80 to 255
        
        # Create blue-to-cyan gradient based on position
        blue_component = int(200 + 55 * fade_factor)  # Blue channel: 200-255
        green_component = int(100 * fade_factor)      # Green channel: 0-100
        
        hex_red = to_hex_string(brightness // 3)      # Dim red for blue-ish color
        hex_green = to_hex_string(green_component)    # Variable green
        hex_blue = to_hex_string(blue_component)      # Bright blue
        
        dot_color = "#" + hex_red + hex_green + hex_blue
        
        # Render larger dots (3x3 instead of 2x2) and ensure they're within reasonable bounds
        if dot_x >= -1 and dot_x <= x + size + 1 and dot_y >= -1 and dot_y <= y + size + 1:
            # Main dot (3x3)
            elements.append(
                render.Padding(
                    pad = (dot_x, dot_y, 0, 0),
                    child = render.Box(
                        width = 3,
                        height = 3,
                        color = dot_color,
                    ),
                )
            )
            
            # Add a bright center pixel for leading dots
            if i < 3:  # Only for the first 3 dots (leading edge)
                bright_center = "#" + to_hex_string(255) + to_hex_string(255) + to_hex_string(255)
                elements.append(
                    render.Padding(
                        pad = (dot_x + 1, dot_y + 1, 0, 0),
                        child = render.Box(
                            width = 1,
                            height = 1,
                            color = bright_center,
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
