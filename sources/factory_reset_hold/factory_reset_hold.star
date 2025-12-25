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

    frames = create_hold_animation(width, height)

    return render.Root(
        delay = 100,  # 100ms per frame
        child = render.Animation(
            children = frames,
        ),
    )

def create_hold_animation(width, height):
    """Creates factory reset hold animation with filling progress circle"""
    frames = []
    num_frames = 50  # 5 second hold simulation

    for frame_idx in range(num_frames):
        elements = []

        # Dark red/orange background (warning color)
        elements.append(
            render.Box(
                width = width,
                height = height,
                color = "#1a0a00",
            )
        )

        # Determine layout based on screen aspect ratio
        is_rectangular = width > height * 1.5

        if is_rectangular:
            # Rectangular: exclamation on left, text on right
            elements.extend(create_horizontal_layout(width, height, frame_idx))
        else:
            # Square/portrait: exclamation in center, text at bottom
            elements.extend(create_vertical_layout(width, height, frame_idx))

        frame = render.Stack(children = elements)
        frames.append(frame)

    return frames

def create_vertical_layout(width, height, frame_idx):
    """Create vertical layout for square/portrait screens"""
    elements = []

    # Warning icon in center
    elements.extend(create_warning_icon(width // 2, height // 2))

    # Text at bottom
    font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
    char_width = 4 if font_name == "tom-thumb" else 6
    text_height = 5 if font_name == "tom-thumb" else 13

    # Pulsing text
    text_alpha = (math.sin(frame_idx * 0.3) + 1) / 2
    text_brightness = int(200 + 55 * text_alpha)

    text_content = "hold"
    text_width = len(text_content) * char_width
    text_x = max(0, math.floor((width - text_width) / 2))
    text_y = height - text_height - 2

    hex_r = to_hex_string(text_brightness)
    hex_g = to_hex_string(text_brightness // 2)
    text_color = "#" + hex_r + hex_g + "00"

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

def create_horizontal_layout(width, height, frame_idx):
    """Create horizontal layout for rectangular screens"""
    elements = []

    # Icon on left side
    icon_x = width // 4
    icon_y = height // 2
    elements.extend(create_warning_icon(icon_x, icon_y))

    # Text on right side
    font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
    char_width = 4 if font_name == "tom-thumb" else 6
    text_height = 5 if font_name == "tom-thumb" else 13

    # Pulsing text
    text_alpha = (math.sin(frame_idx * 0.3) + 1) / 2
    text_brightness = int(200 + 55 * text_alpha)

    text_content = "hold"
    text_width = len(text_content) * char_width
    text_x = (width // 2) + (width // 4) - (text_width // 2)
    text_y = max(0, math.floor((height - text_height) / 2))

    hex_r = to_hex_string(text_brightness)
    hex_g = to_hex_string(text_brightness // 2)
    text_color = "#" + hex_r + hex_g + "00"

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

def create_warning_icon(center_x, center_y):
    """Create warning exclamation mark icon at given position"""
    elements = []

    # Exclamation mark
    # Vertical line (top part)
    for y in range(6):
        elements.append(
            render.Padding(
                pad = (center_x - 1, center_y - 4 + y, 0, 0),
                child = render.Box(
                    width = 2,
                    height = 1,
                    color = "#ff6600",
                ),
            )
        )

    # Dot (bottom part)
    elements.append(
        render.Padding(
            pad = (center_x - 1, center_y + 3, 0, 0),
            child = render.Box(
                width = 2,
                height = 2,
                color = "#ff6600",
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
