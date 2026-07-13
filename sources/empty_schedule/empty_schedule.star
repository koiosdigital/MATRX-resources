"""
MATRX Empty Schedule - No apps installed
A lonely desert night: twinkling stars, a saguaro cactus, the
occasional shooting star, and a tumbleweed rolling past.
"""

load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")
load("random.star", "random")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

NUM_FRAMES = 60

CACTUS = [
    "...#...",
    "#..#..#",
    "#..#..#",
    "#..#..#",
    ".#####.",
    "...#...",
    "...#...",
    "...#...",
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
        child = render.Box(
            width = size,
            height = size,
            color = color,
        ),
    )

def draw_bitmap(bitmap, origin_x, origin_y, color, px):
    """Draw a bitmap ('#' = block) with px-by-px blocks per cell"""
    elements = []

    for row_idx, row in enumerate(bitmap):
        for col_idx in range(len(row)):
            if row[col_idx] == "#":
                elements.append(block(origin_x + col_idx * px, origin_y + row_idx * px, color, px))

    return elements

def main(config):
    width = int(config.str("width", DEFAULT_WIDTH))
    height = int(config.str("height", DEFAULT_HEIGHT))

    frames = create_desert_animation(width, height)

    return render.Root(
        delay = 100,  # 100ms per frame
        child = render.Animation(
            children = frames,
        ),
    )

def create_stars(width, height):
    """Precompute star positions and twinkle phases"""
    stars = []
    num_stars = max(8, (width * height) // 180)

    for star_idx in range(num_stars):
        random.seed(7000 + star_idx)
        stars.append({
            "x": random.number(0, width - 1),
            "y": random.number(0, (height * 2) // 3),
            "phase": random.number(0, 62),
            "speed": random.number(10, 30) / 100.0,
        })

    return stars

def create_desert_animation(width, height):
    """Build the looping desert night scene"""
    frames = []

    # Everything chunks up on bigger panels
    scale = 2 if min(width, height) >= 64 else 1

    ground_y = height - 3 * scale
    stars = create_stars(width, height)

    for frame_idx in range(NUM_FRAMES):
        elements = []

        # Twinkling stars
        for star in stars:
            twinkle = (math.sin(frame_idx * star["speed"] + star["phase"]) + 1) / 2
            brightness = int(70 + 150 * twinkle)
            hex_val = to_hex_string(brightness)
            elements.append(block(star["x"], star["y"], "#" + hex_val + hex_val + hex_val, scale))

        # Shooting star streaks across the sky once per loop
        elements.extend(create_shooting_star(width, height, frame_idx, scale))

        # Ground line with a few pebbles
        for x in range(0, width, scale):
            random.seed(3000 + x)
            bump = scale if random.number(0, 100) > 85 else 0
            elements.append(block(x, ground_y - bump, "#3a2a1a", scale))

        # A lonely saguaro
        cactus_x = width // 6
        elements.extend(draw_bitmap(CACTUS, cactus_x, ground_y - len(CACTUS) * scale, "#1d7a2f", scale))

        # Tumbleweed rolls in front of everything
        elements.extend(create_tumbleweed(width, ground_y, frame_idx, scale))

        frames.append(render.Stack(children = elements))

    return frames

def create_shooting_star(width, height, frame_idx, scale):
    """Brief diagonal streak around the middle of the loop"""
    elements = []

    streak_start = 32
    streak_len = 6

    if frame_idx >= streak_start and frame_idx < streak_start + streak_len:
        progress = frame_idx - streak_start
        head_x = (width * 3) // 4 - progress * 4 * scale
        head_y = 2 + progress * 2 * scale

        for tail_idx in range(4):
            x = head_x + tail_idx * 2 * scale
            y = head_y - tail_idx * scale

            if x >= 0 and x < width and y >= 0 and y < height:
                brightness = 255 - tail_idx * 55
                hex_val = to_hex_string(brightness)
                elements.append(block(x, y, "#" + hex_val + hex_val + hex_val, scale))

    return elements

def create_tumbleweed(width, ground_y, frame_idx, scale):
    """A scraggly ball of twigs rolling and bouncing across the screen"""
    elements = []

    weed_r = 4 * scale
    travel = width + weed_r * 4
    center_x = ((frame_idx * travel) // NUM_FRAMES) - weed_r * 2

    # Small bounce as it rolls
    bounce = int(abs(math.sin(frame_idx * 0.5)) * 3 * scale)
    center_y = ground_y - weed_r - scale - bounce

    # Outer ring of twigs, rotating as it rolls
    spin = frame_idx * 0.6
    for spoke_idx in range(10):
        angle = spin + 2 * math.pi * spoke_idx / 10
        x = int(center_x + weed_r * math.cos(angle))
        y = int(center_y + weed_r * math.sin(angle))

        if x >= 0 and x < width:
            elements.append(block(x, y, "#a8804a", scale))

    # Inner tangle, spinning the other way
    for spoke_idx in range(5):
        angle = -spin + 2 * math.pi * spoke_idx / 5
        x = int(center_x + (weed_r // 2) * math.cos(angle))
        y = int(center_y + (weed_r // 2) * math.sin(angle))

        if x >= 0 and x < width:
            elements.append(block(x, y, "#7a5c33", scale))

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
