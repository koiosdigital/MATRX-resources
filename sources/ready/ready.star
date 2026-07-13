"""
MATRX Ready Variant 3 - Playing catch
Two little friends play catch under the stars, tossing a glowing
ball back and forth — the friendliest possible picture of two
devices keeping in sync.
"""

load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")
load("random.star", "random")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

NUM_FRAMES = 40
THROW_FRAMES = 20  # one throw each direction per loop

# Kid sprites: H = head, S = shirt, L = legs
KID_ARMS_DOWN = [
    "..HH..",
    "..HH..",
    ".SSSS.",
    "S.SS.S",
    "..SS..",
    "..LL..",
    ".L..L.",
    ".L..L.",
]

# Facing right, reaching for the ball; mirrored for facing left
KID_ARMS_UP = [
    "..HH.S",
    "..HHS.",
    ".SSSS.",
    "S.SS..",
    "..SS..",
    "..LL..",
    ".L..L.",
    ".L..L.",
]

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

def block(x, y, color, size):
    return render.Padding(
        pad = (x, y, 0, 0),
        child = render.Box(width = size, height = size, color = color),
    )

def main(config):
    width = int(config.str("width", DEFAULT_WIDTH))
    height = int(config.str("height", DEFAULT_HEIGHT))

    frames = create_catch_animation(width, height)

    return render.Root(
        delay = 90,  # 90ms per frame
        child = render.Animation(children = frames),
    )

def draw_kid(x, y, shirt_color, arms_up, facing_right, px):
    """A chunky little friend; arms reach up to throw and catch"""
    elements = []

    sprite = KID_ARMS_UP if arms_up else KID_ARMS_DOWN
    colors = {
        "H": "#e8c090",
        "S": shirt_color,
        "L": "#5070a0",
    }

    for row_idx, row in enumerate(sprite):
        for col_idx in range(len(row)):
            cell = row[col_idx]
            if cell == ".":
                continue

            # Mirror the sprite when facing left
            draw_col = col_idx if facing_right else len(row) - 1 - col_idx
            elements.append(block(x + draw_col * px, y + row_idx * px, colors[cell], px))

    return elements

def create_catch_animation(width, height):
    frames = []

    # Everything chunks up on bigger panels
    scale = 2 if min(width, height) >= 64 else 1
    kid_w = 6 * scale
    kid_h = 8 * scale
    ball_size = scale + 1

    ground_y = height - scale
    kid_y = ground_y - kid_h
    left_x = max(1, width // 10)
    right_x = width - kid_w - max(1, width // 10)

    hand_y = kid_y + scale  # about where raised hands are
    arc_height = max(6, height // 3)

    for frame_idx in range(NUM_FRAMES):
        elements = []
        cycle = 2 * math.pi * frame_idx / NUM_FRAMES

        # Twinkling stars
        for star_idx in range(6):
            random.seed(9100 + star_idx)
            star_x = random.number(0, width - 1)
            star_y = random.number(0, height // 3)
            twinkle = (math.sin(cycle * 2 + star_idx * 2) + 1) / 2
            hex_val = to_hex_string(int(50 + 110 * twinkle))
            elements.append(block(star_x, star_y, "#" + hex_val + hex_val + hex_val, scale))

        # Ground with little grass tufts
        for x in range(0, width, scale):
            elements.append(block(x, ground_y, "#204a20", scale))
            random.seed(9200 + x)
            if random.number(0, 100) > 80:
                elements.append(block(x, ground_y - scale, "#183a18", scale))

        # Message
        elements.extend(create_message(width, height, frame_idx))

        # Whose throw is it?
        throw_idx = frame_idx // THROW_FRAMES  # 0: left->right, 1: right->left
        t = (frame_idx % THROW_FRAMES) / (THROW_FRAMES - 1)

        if throw_idx == 0:
            start_x, end_x = left_x + kid_w, right_x - ball_size
        else:
            start_x, end_x = right_x - ball_size, left_x + kid_w

        ball_x = int(start_x + (end_x - start_x) * t)
        ball_y = int(hand_y - arc_height * math.sin(math.pi * t))

        # Kids raise their arms to throw and catch
        left_arms_up = (throw_idx == 0 and t < 0.25) or (throw_idx == 1 and t > 0.75)
        right_arms_up = (throw_idx == 1 and t < 0.25) or (throw_idx == 0 and t > 0.75)

        elements.extend(draw_kid(left_x, kid_y, "#e05050", left_arms_up, True, scale))
        elements.extend(draw_kid(right_x, kid_y, "#40b070", right_arms_up, False, scale))

        # Glowing ball with a fading trail
        for trail_idx in range(1, 3):
            trail_t = t - trail_idx * 0.08
            if trail_t > 0:
                trail_x = int(start_x + (end_x - start_x) * trail_t)
                trail_y = int(hand_y - arc_height * math.sin(math.pi * trail_t))
                fade = to_hex_string(120 - trail_idx * 50)
                elements.append(block(trail_x, trail_y, "#" + fade + fade + "00", scale))

        elements.append(block(ball_x, ball_y, "#ffee44", ball_size))

        # Catch spark
        if t > 0.94:
            elements.append(block(ball_x, ball_y - ball_size, "#ffffff", scale))

        frames.append(render.Stack(children = elements))

    return frames

def create_message(width, height, frame_idx):
    """Gently pulsing 'syncing' message"""
    elements = []

    font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
    char_width = 4 if font_name == "tom-thumb" else 6
    text_height = 5 if font_name == "tom-thumb" else 13

    text_content = "syncing"
    text_width = len(text_content) * char_width
    text_x = max(0, math.floor((width - text_width) / 2))
    text_y = max(0, math.floor((height - text_height) / 2))

    pulse = (math.sin(frame_idx * 0.2) + 1) / 2
    brightness = int(150 + 105 * pulse)
    hex_val = to_hex_string(brightness)

    elements.append(
        render.Padding(
            pad = (text_x, text_y, 0, 0),
            child = render.Text(
                content = text_content,
                color = "#" + hex_val + hex_val + hex_val,
                font = font_name,
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
