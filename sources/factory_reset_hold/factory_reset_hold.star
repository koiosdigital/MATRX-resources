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
    """Creates factory reset hold animation with progress bar at bottom"""
    frames = []
    num_frames = 30  # 3 seconds at 100ms per frame

    for frame_idx in range(num_frames):
        elements = []

        # Calculate progress (0.0 to 1.0)
        progress = frame_idx / (num_frames - 1)

        # Center position for exclamation (slightly above center to make room for bar)
        center_x = width // 2
        center_y = (height // 2) - 2

        # Draw exclamation mark in center
        elements.extend(create_warning_icon(center_x, center_y))

        # Draw progress bar at bottom that grows from center
        elements.extend(create_progress_bar(width, height, progress))

        frame = render.Stack(children = elements)
        frames.append(frame)

    return frames

def create_progress_bar(width, height, progress):
    """Create progress bar at bottom that grows from center"""
    elements = []

    bar_height = 3
    bar_y = height - bar_height - 1  # 1px from bottom

    # Calculate bar width based on progress (grows from center)
    max_bar_width = width - 4  # Leave 2px margin on each side
    current_bar_width = int(max_bar_width * progress)

    if current_bar_width > 0:
        # Center the bar horizontally
        bar_x = (width - current_bar_width) // 2

        elements.append(
            render.Padding(
                pad = (bar_x, bar_y, 0, 0),
                child = render.Box(
                    width = current_bar_width,
                    height = bar_height,
                    color = "#ff6600",
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
