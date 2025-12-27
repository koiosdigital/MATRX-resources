load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

def main(config):
    width = int(config.str("width", DEFAULT_WIDTH))
    height = int(config.str("height", DEFAULT_HEIGHT))

    # Create keygen animation frames
    keygen_frames = create_keygen_animation(width, height)

    return render.Root(
        delay = 500,  # 500ms per frame for ellipsis animation
        child = render.Animation(
            children = keygen_frames,
        ),
    )

def create_keygen_animation(width, height):
    """Creates keygen animation with animated ellipsis"""
    frames = []

    # 4 frames for ellipsis animation (0, 1, 2, 3 dots)
    num_frames = 4

    for frame_idx in range(num_frames):
        elements = []

        # Choose font based on screen size
        use_small_font = width < 32 or height < 32
        font_name = "tom-thumb" if use_small_font else "6x13"
        text_height = 5 if use_small_font else 13
        char_width = 4 if use_small_font else 6

        # Text with animated ellipsis
        ellipsis_count = frame_idx  # 0, 1, 2, 3
        text_content = "keygen" + ("." * ellipsis_count)
        text_width = len(text_content) * char_width
        text_x = max(0, math.floor((width - text_width) / 2))
        text_y = max(0, math.floor((height - text_height) / 2))

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

        frame = render.Stack(children = elements)
        frames.append(frame)

    return frames

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
