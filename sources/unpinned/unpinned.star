"""
MATRX Unpinned State - Pushpin icon with "unpinned" text
"""

load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

def main(config):
    """Main entry point for the unpinned animation"""
    width = int(config.get("width", DEFAULT_WIDTH))
    height = int(config.get("height", DEFAULT_HEIGHT))

    frames = create_unpinned_animation(width, height)

    return render.Root(
        delay = 100,  # 100ms per frame
        child = render.Animation(children = frames),
    )

def create_unpinned_animation(width, height):
    """Creates unpinned animation with icon only"""
    frames = []
    num_frames = 30  # Pulsing animation

    for frame_idx in range(num_frames):
        elements = []

        # Center the icon vertically and horizontally
        elements.extend(create_pushpin_icon(width // 2, height // 2))

        frame = render.Stack(children = elements)
        frames.append(frame)

    return frames

def create_pushpin_icon(center_x, center_y):
    """Create large pushpin icon with X through it"""
    elements = []

    # Pin head (circle, red/dimmed) - diameter 11 (radius ~5)
    diameter = 11
    head_center_y = center_y - 6

    elements.append(
        render.Padding(
            pad = (center_x - diameter // 2, head_center_y - diameter // 2, 0, 0),
            child = render.Circle(
                diameter = diameter,
                color = "#aa2222",  # Dimmer red to show unpinned
            ),
        )
    )

    # Pin needle (pointing down from head, silver/gray, dimmed)
    needle_start_y = head_center_y + diameter // 2 + 1
    for i in range(10):
        elements.append(
            render.Padding(
                pad = (center_x - 1, needle_start_y + i, 0, 0),
                child = render.Box(
                    width = 2,
                    height = 1,
                    color = "#666666",  # Darker gray to show unpinned
                ),
            )
        )

    # X slash through the pin (to indicate unpinned/disabled)
    # Diagonal from top-left to bottom-right
    for i in range(20):
        elements.append(
            render.Padding(
                pad = (center_x - 10 + i, center_y - 12 + i, 0, 0),
                child = render.Box(
                    width = 2,
                    height = 2,
                    color = "#ffffff",
                ),
            )
        )

    # Diagonal from top-right to bottom-left
    for i in range(20):
        elements.append(
            render.Padding(
                pad = (center_x + 9 - i, center_y - 12 + i, 0, 0),
                child = render.Box(
                    width = 2,
                    height = 2,
                    color = "#ffffff",
                ),
            )
        )

    return elements

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
