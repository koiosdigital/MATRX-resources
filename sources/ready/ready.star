load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")
load("random.star", "random")

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
    
    # Create cloud animation frames
    cloud_frames = create_cloud_animation(width, height)
    
    return render.Root(
        delay = 120,  # 120ms per frame for smooth cloud drift
        child = render.Animation(
            children = cloud_frames,
        ),
    )

def create_cloud_animation(width, height):
    """Creates demo loop with matrix rain effect and cycling stats"""
    frames = []
    num_frames = 120  # Longer loop for demo

    for frame_idx in range(num_frames):
        elements = []

        # Matrix-style rain effect in background
        elements.extend(create_matrix_rain(width, height, frame_idx))
        elements.extend(create_ready_display(width, height, frame_idx))
        frame = render.Stack(children = elements)
        frames.append(frame)

    return frames

def create_matrix_rain(width, height, frame_idx):
    """Create matrix-style falling characters effect"""
    elements = []

    # Create vertical streams of falling pixels
    random.seed(42)  # Deterministic rain
    num_streams = width // 4

    for stream_idx in range(num_streams):
        x = stream_idx * 4 + 1

        # Each stream has different speed and offset
        random.seed(100 + stream_idx)
        speed = random.number(1, 3)
        offset = random.number(0, 20)

        y_pos = ((frame_idx * speed + offset) % (height + 10)) - 10

        # Draw stream (fade trail)
        for trail_idx in range(5):
            y = int(y_pos - trail_idx * 2)

            if y >= 0 and y < height:
                opacity = int(80 * (5 - trail_idx) / 5)
                hex_g = to_hex_string(opacity)
                color = "#00" + hex_g + "00"

                elements.append(
                    render.Padding(
                        pad = (x, y, 0, 0),
                        child = render.Box(
                            width = 1,
                            height = 1,
                            color = color,
                        ),
                    )
                )

    return elements

def create_ready_display(width, height, frame_idx):
    """Display ready text with pulse"""
    elements = []

    # Pulsing effect
    pulse = (math.sin(frame_idx * 0.3) + 1) / 2
    brightness = int(150 + 105 * pulse)

    hex_val = to_hex_string(brightness)
    text_color = "#00" + hex_val + "00"

    font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
    char_width = 4 if font_name == "tom-thumb" else 6
    text_height = 5 if font_name == "tom-thumb" else 13

    text_content = "ready"
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