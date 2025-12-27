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
    """Creates factory reset success animation with checkmark and text"""
    frames = []
    num_frames = 30

    for frame_idx in range(num_frames):
        elements = []

        # Checkmark at same position as arrow in check_updates (center_y - 3)
        center_x = width // 2
        center_y = (height // 2) - 3
        elements.extend(create_checkmark(center_x, center_y))

        # Success text at bottom
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

def create_checkmark(center_x, center_y):
    """Create checkmark icon at given position"""
    elements = []

    # Checkmark shape - short left stroke and longer right stroke
    # Left stroke (going down-right)
    left_stroke = [
        (-4, -1), (-3, 0), (-2, 1), (-1, 2)
    ]

    # Right stroke (going up-right from the bottom of left stroke)
    right_stroke = [
        (0, 1), (1, 0), (2, -1), (3, -2), (4, -3), (5, -4)
    ]

    for dx, dy in left_stroke:
        elements.append(
            render.Padding(
                pad = (center_x + dx, center_y + dy, 0, 0),
                child = render.Box(
                    width = 2,
                    height = 2,
                    color = "#00ff00",
                ),
            )
        )

    for dx, dy in right_stroke:
        elements.append(
            render.Padding(
                pad = (center_x + dx, center_y + dy, 0, 0),
                child = render.Box(
                    width = 2,
                    height = 2,
                    color = "#00ff00",
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
