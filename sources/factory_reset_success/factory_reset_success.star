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

    frames = create_success_animation(width, height)

    return render.Root(
        delay = 80,  # 80ms per frame
        child = render.Animation(
            children = frames,
        ),
    )

def create_success_animation(width, height):
    """Creates factory reset success animation with checkmark and expanding rings"""
    frames = []
    num_frames = 30

    for frame_idx in range(num_frames):
        elements = []

        # Dark green background
        elements.append(
            render.Box(
                width = width,
                height = height,
                color = "#001a00",
            )
        )

        # Expanding success rings
        if frame_idx < 20:
            elements.extend(create_success_rings(width, height, frame_idx))

        # Success text
        font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
        char_width = 4 if font_name == "tom-thumb" else 6
        text_height = 5 if font_name == "tom-thumb" else 13

        text_content = "reset OK"
        text_width = len(text_content) * char_width
        text_x = max(0, math.floor((width - text_width) / 2))
        text_y = height - text_height - 2

        # Gentle pulse
        text_alpha = (math.sin(frame_idx * 0.2) + 1) / 2
        text_brightness = int(180 + 75 * text_alpha)
        hex_g = to_hex_string(text_brightness)
        text_color = "#00" + hex_g + "00"

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

def create_success_rings(width, height, frame_idx):
    """Create expanding rings for success effect"""
    elements = []

    center_x = width // 2
    center_y = height // 2

    # Two rings expanding outward
    for ring_idx in range(2):
        ring_frame = frame_idx - ring_idx * 5

        if ring_frame >= 0 and ring_frame < 20:
            radius = 4 + int(ring_frame * 1.5)

            # Fade out as ring expands
            opacity = int(255 * (1 - ring_frame / 20.0))
            hex_g = to_hex_string(opacity)
            ring_color = "#00" + hex_g + "00"

            elements.extend(draw_circle(center_x, center_y, radius, ring_color))

    return elements

def draw_circle(cx, cy, radius, color):
    """Draw a circle outline"""
    pixels = []

    if radius < 1:
        return pixels

    num_points = max(12, radius * 6)

    for i in range(num_points):
        angle = (i * 360 / num_points) * math.pi / 180
        x = int(cx + radius * math.cos(angle))
        y = int(cy + radius * math.sin(angle))

        pixels.append(
            render.Padding(
                pad = (x, y, 0, 0),
                child = render.Box(
                    width = 1,
                    height = 1,
                    color = color,
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
