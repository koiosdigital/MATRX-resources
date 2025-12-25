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

    frames = create_wifi_animation(width, height)

    return render.Root(
        delay = 100,  # 100ms per frame
        child = render.Animation(
            children = frames,
        ),
    )

def create_wifi_animation(width, height):
    """Creates WiFi connection animation with scanning waves"""
    frames = []
    num_frames = 30  # 30 frames for smooth loop

    for frame_idx in range(num_frames):
        elements = []

        # Dark cyan background
        elements.append(
            render.Box(
                width = width,
                height = height,
                color = "#001420",
            )
        )

        # Add scanning waves effect
        elements.extend(create_scanning_waves(width, height, frame_idx))

        # Add pulsing text with animated ellipsis
        text_alpha = (math.sin(frame_idx * 0.2) + 1) / 2
        text_brightness = int(180 + 75 * text_alpha)
        hex_brightness = to_hex_string(text_brightness)
        text_color = "#00" + hex_brightness + "ff"

        # Choose font based on screen size
        font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
        char_width = 4 if font_name == "tom-thumb" else 6
        text_height = 5 if font_name == "tom-thumb" else 13

        # Cycle ellipsis every 10 frames
        ellipsis_count = (frame_idx // 10) % 4  # 0, 1, 2, 3
        text_content = "wifi" + ("." * ellipsis_count)
        text_width = len(text_content) * char_width
        text_x = max(0, math.floor((width - text_width) / 2))
        text_y = max(0, math.floor((height - text_height) / 2))

        elements.append(
            render.Padding(
                pad = (text_x, text_y, 0, 0),
                child = render.Text(
                    content = text_content,
                    color = text_color,
                    font = font_name
                ),
            )
        )

        frame = render.Stack(children = elements)
        frames.append(frame)

    return frames

def create_scanning_waves(width, height, frame_idx):
    """Create expanding circular waves for scanning effect"""
    elements = []

    center_x = width // 2
    center_y = height // 2

    # Create 3 waves at different phases
    for wave_idx in range(3):
        # Stagger waves
        wave_frame = (frame_idx + wave_idx * 10) % 30

        # Wave expands from center
        max_radius = min(width, height) // 2
        radius = int((wave_frame / 30.0) * max_radius)

        # Fade out as wave expands
        opacity = int(255 * (1 - wave_frame / 30.0))

        # Draw circular wave using pixel approximation
        elements.extend(draw_circle(center_x, center_y, radius, opacity))

    return elements

def draw_circle(cx, cy, radius, opacity):
    """Draw a circle using pixel approximation"""
    pixels = []

    if radius < 1:
        return pixels

    # Use Bresenham-like circle drawing
    num_points = max(8, radius * 6)  # More points for larger circles

    for i in range(num_points):
        angle = (i * 360 / num_points) * math.pi / 180
        x = int(cx + radius * math.cos(angle))
        y = int(cy + radius * math.sin(angle))

        # Cyan color with opacity
        cyan = min(255, 180 + opacity // 3)
        hex_color = "#00" + to_hex_string(opacity // 2) + to_hex_string(cyan)

        pixels.append(
            render.Padding(
                pad = (x, y, 0, 0),
                child = render.Box(
                    width = 1,
                    height = 1,
                    color = hex_color,
                ),
            )
        )

    return pixels

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
