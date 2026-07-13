"""
MATRX Boot Variant 2 - Pixel rain assembly
Every pixel of a chunky MATRX wordmark falls from the sky and locks
into place left-to-right, then a cyan shimmer sweeps across the
finished logo.
"""

load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")
load("random.star", "random")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

TOTAL_FRAMES = 40
FALL_DURATION = 8  # frames for one pixel to drop into place

# Same palette as the OG boot fireworks
RAINBOW = ["#ff0000", "#ff8800", "#ffff00", "#00ff00", "#0088ff", "#8800ff"]

# 5x5 pixel font for the MATRX wordmark
LETTERS = {
    "M": [
        "#...#",
        "##.##",
        "#.#.#",
        "#...#",
        "#...#",
    ],
    "A": [
        ".###.",
        "#...#",
        "#####",
        "#...#",
        "#...#",
    ],
    "T": [
        "#####",
        "..#..",
        "..#..",
        "..#..",
        "..#..",
    ],
    "R": [
        "####.",
        "#...#",
        "####.",
        "#..#.",
        "#...#",
    ],
    "X": [
        "#...#",
        ".#.#.",
        "..#..",
        ".#.#.",
        "#...#",
    ],
}

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
    width = int(config.get("width", DEFAULT_WIDTH))
    height = int(config.get("height", DEFAULT_HEIGHT))

    frames = create_assembly_animation(width, height)

    return render.Root(
        delay = 70,  # 70ms per frame
        child = render.Animation(children = frames),
    )

def build_target_pixels(width, height):
    """Compute the final resting position for every logo pixel"""
    word = "MATRX"
    scale = max(1, min(width // 32, height // 8))

    letter_width = 5 * scale
    letter_gap = scale
    word_width = len(word) * letter_width + (len(word) - 1) * letter_gap
    word_height = 5 * scale

    origin_x = max(0, (width - word_width) // 2)
    origin_y = max(0, (height - word_height) // 2)

    pixels = []
    for letter_idx in range(len(word)):
        bitmap = LETTERS[word[letter_idx]]
        letter_x = origin_x + letter_idx * (letter_width + letter_gap)

        for row_idx, row in enumerate(bitmap):
            for col_idx in range(len(row)):
                if row[col_idx] == "#":
                    target_x = letter_x + col_idx * scale
                    target_y = origin_y + row_idx * scale

                    # Left-to-right wave, plus a little randomness per pixel
                    random.seed(target_x * 31 + target_y * 7)
                    start_frame = (target_x * 16) // max(1, width) + random.number(0, 4)

                    pixels.append({
                        "x": target_x,
                        "y": target_y,
                        "start": start_frame,
                    })

    return pixels, scale

def create_assembly_animation(width, height):
    frames = []
    pixels, scale = build_target_pixels(width, height)

    # First frame where every pixel has finished falling
    assembled_at = 0
    for px in pixels:
        landing = px["start"] + FALL_DURATION
        if landing > assembled_at:
            assembled_at = landing

    for frame_idx in range(TOTAL_FRAMES):
        elements = [
            render.Box(width = width, height = height, color = "#000000"),
        ]

        for px in pixels:
            if frame_idx < px["start"]:
                continue  # not yet released

            progress = (frame_idx - px["start"]) / FALL_DURATION
            if progress > 1:
                progress = 1

            if progress < 1:
                # Ease-in fall (gravity), dimmer while airborne
                eased = progress * progress
                y = int(-scale - 2 + (px["y"] + scale + 2) * eased)
                color = "#8a8a8a"
            else:
                y = px["y"]
                color = "#ffffff"

                # Rainbow shimmer sweep once fully assembled
                if frame_idx > assembled_at:
                    sweep_x = (frame_idx - assembled_at) * (width // 8) - width // 4
                    band_width = max(1, width // 4)
                    dist = abs(px["x"] - sweep_x)
                    if dist < band_width:
                        color = RAINBOW[(dist * len(RAINBOW)) // band_width]

            if y + scale > 0:
                elements.append(
                    render.Padding(
                        pad = (px["x"], max(0, y), 0, 0),
                        child = render.Box(
                            width = scale,
                            height = scale,
                            color = color,
                        ),
                    )
                )

        frames.append(render.Stack(children = elements))

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
