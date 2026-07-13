"""
MATRX Connecting Variant 2 - Fireflies
Two fireflies blink out of sync on opposite sides of a night meadow,
drift toward each other, and finally hover together blinking in
perfect unison with little sparkles.
"""

load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")
load("random.star", "random")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

NUM_FRAMES = 64
MEET_FRAME = 40  # frame by which the fireflies are together

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

    frames = create_firefly_animation(width, height)

    return render.Root(
        delay = 100,  # 100ms per frame
        child = render.Animation(children = frames),
    )

def draw_firefly(x, y, glow, size):
    """Chunky body with a tail-light; halo blooms when glowing bright"""
    elements = []

    elements.append(block(x, y, "#555544", size))

    if glow > 30:
        hex_val = to_hex_string(glow)
        elements.append(block(x + size, y, "#" + hex_val + hex_val + "20", size))

        if glow > 180:
            halo_hex = to_hex_string(glow // 3)
            halo = "#" + halo_hex + halo_hex + "10"
            elements.append(block(x + size * 2, y, halo, size))
            elements.append(block(x + size, y - size, halo, size))
            elements.append(block(x + size, y + size, halo, size))
            elements.append(block(x, y - size, halo, size))
            elements.append(block(x, y + size, halo, size))

    return elements

def create_firefly_animation(width, height):
    frames = []

    # Everything chunks up on bigger panels
    scale = 2 if min(width, height) >= 64 else 1
    fly_size = scale + 1

    meet_x = width // 2
    meet_y = height // 4

    for frame_idx in range(NUM_FRAMES):
        elements = []

        # A few dim stars
        for star_idx in range(5):
            random.seed(7700 + star_idx)
            star_x = random.number(0, width - 1)
            star_y = random.number(0, height // 3)
            twinkle = (math.sin(frame_idx * 0.3 + star_idx * 2) + 1) / 2
            hex_val = to_hex_string(int(50 + 90 * twinkle))
            elements.append(block(star_x, star_y, "#" + hex_val + hex_val + hex_val, scale))

        # Grass along the bottom, taller on bigger panels
        for x in range(0, width, scale):
            random.seed(7800 + x)
            blade = random.number(1, 2 + scale)
            for blade_y in range(blade):
                shade = to_hex_string(40 + blade_y * 12)
                elements.append(block(x, height - (blade_y + 1) * scale, "#10" + shade + "10", scale))

        # Message
        elements.extend(create_message(width, height, frame_idx))

        # How far along the courtship we are (0 = apart, 1 = together)
        progress = min(1.0, frame_idx / MEET_FRAME)
        ease = progress * progress * (3 - 2 * progress)  # smoothstep

        wobble_y = 3 * scale * math.sin(frame_idx * 0.5)

        # Left firefly: blinks fast at first, settles into the shared rhythm
        left_home = 2 + scale
        left_x = int(left_home + (meet_x - fly_size * 2 - left_home) * ease)
        left_y = int(meet_y + (1 - ease) * (height // 3) + wobble_y * (1 - ease * 0.7))
        left_rate = 0.9 - 0.4 * ease
        left_glow = int(255 * max(0.0, math.sin(frame_idx * left_rate)))

        # Right firefly: blinks slow at first
        right_home = width - 3 - fly_size * 2
        right_x = int(right_home - (right_home - meet_x - fly_size) * ease)
        right_y = int(meet_y + (1 - ease) * (height // 4) - wobble_y * (1 - ease * 0.7))
        right_rate = 0.3 + 0.2 * ease
        right_glow = int(255 * max(0.0, math.sin(frame_idx * right_rate)))

        # Once together, they pulse as one
        if frame_idx >= MEET_FRAME:
            unison = int(255 * max(0.0, math.sin(frame_idx * 0.5)))
            left_glow = unison
            right_glow = unison

            # Sparkles ring out on the bright beats
            if unison > 200:
                for spark_idx in range(4):
                    angle = frame_idx * 0.7 + spark_idx * math.pi / 2
                    spark_x = int(meet_x + 5 * scale * math.cos(angle))
                    spark_y = int(meet_y + 4 * scale * math.sin(angle))
                    if spark_x >= 0 and spark_x < width and spark_y >= 0:
                        elements.append(block(spark_x, spark_y, "#ffff88", scale))

        elements.extend(draw_firefly(left_x, left_y, left_glow, fly_size))
        elements.extend(draw_firefly(right_x, right_y, right_glow, fly_size))

        frames.append(render.Stack(children = elements))

    return frames

def create_message(width, height, frame_idx):
    """Gently pulsing 'connecting' message"""
    elements = []

    font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
    char_width = 4 if font_name == "tom-thumb" else 6
    text_height = 5 if font_name == "tom-thumb" else 13

    text_content = "connecting"
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
