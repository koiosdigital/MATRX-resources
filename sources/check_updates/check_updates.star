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
    
    # Create cloud animation frames
    cloud_frames = create_cloud_animation(width, height)
    
    return render.Root(
        delay = 120,  # 120ms per frame for smooth cloud drift
        child = render.Animation(
            children = cloud_frames,
        ),
    )

def create_cloud_animation(width, height):
    """Creates update checking animation with download progress and arrows"""
    frames = []
    num_frames = 60

    for frame_idx in range(num_frames):
        elements = []

        # Animated download arrow
        elements.extend(create_download_arrow(width, height, frame_idx))

        # Text with animated ellipsis
        font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
        char_width = 4 if font_name == "tom-thumb" else 6
        text_height = 5 if font_name == "tom-thumb" else 13

        text_brightness = 255
        text_color = "#ffffff"

        # Cycle ellipsis every 20 frames
        ellipsis_count = (frame_idx // 20) % 4  # 0, 1, 2, 3
        text_content = "updating" + ("." * ellipsis_count)
        text_width = len(text_content) * char_width
        text_x = max(0, math.floor((width - text_width) / 2))
        text_y = height - text_height - 2

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

def create_download_arrow(width, height, frame_idx):
    """Create animated download arrow bouncing up and down"""
    elements = []

    center_x = width // 2
    center_y = (height // 2) - 3

    # Bounce animation
    bounce_offset = int(3 * math.sin(frame_idx * 0.3))
    arrow_y = center_y + bounce_offset

    # Arrow shaft (vertical line)
    for y in range(8):
        elements.append(
            render.Padding(
                pad = (center_x, arrow_y - 8 + y, 0, 0),
                child = render.Box(
                    width = 1,
                    height = 1,
                    color = "#00aaff",
                ),
            )
        )

    # Arrow head (pointing down)
    arrowhead_points = [
        (-4, -2), (-3, -1), (-2, 0), (-1, 1), (0, 2),
        (4, -2), (3, -1), (2, 0), (1, 1), (0, 2),
    ]

    for dx, dy in arrowhead_points:
        elements.append(
            render.Padding(
                pad = (center_x + dx, arrow_y + dy, 0, 0),
                child = render.Box(
                    width = 1,
                    height = 1,
                    color = "#00aaff",
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