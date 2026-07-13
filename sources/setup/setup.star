"""
MATRX Setup
A scannable QR code (https://koios.sh/kdapp) on the left, and the
bluetooth symbol with its orbiting spinner on the right.
"""

load("render.star", "render")
load("schema.star", "schema")
load("qrcode.star", "qrcode")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

SETUP_URL = "https://koios.sh/kdapp"
QR_MODULES = 25  # 'medium' renders this URL as a 25x25 code

BT_COLOR = "#2196f3"

# Spinner gradient colors (brightest at the head)
SPINNER_COLORS = ["#ffffff", "#dddddd", "#b9b9b9", "#959595", "#717171"]

# Spinner path - 56 positions around the bluetooth symbol (clockwise),
# relative to the bluetooth center
SPINNER_PATH_RELATIVE = [
    (10, 0), (10, 1), (10, 2), (10, 3), (9, 4), (9, 5), (8, 6), (7, 7),
    (6, 8), (5, 8), (4, 9), (3, 9), (2, 9), (1, 9), (0, 9), (-1, 9),
    (-2, 9), (-3, 9), (-4, 8), (-5, 8), (-6, 7), (-7, 6), (-8, 5), (-8, 4),
    (-9, 3), (-9, 2), (-9, 1), (-9, 0), (-9, -1), (-9, -2), (-9, -3), (-9, -4),
    (-8, -5), (-8, -6), (-7, -7), (-6, -8), (-5, -9), (-4, -9), (-3, -10), (-2, -10),
    (-1, -10), (0, -10), (1, -10), (2, -10), (3, -10), (4, -10), (5, -9), (6, -9),
    (7, -8), (8, -7), (9, -6), (9, -5), (10, -4), (10, -3), (10, -2), (10, -1),
]

# Bluetooth symbol pixels relative to its center
BT_PIXELS = [
    (0, -6), (1, -6),
    (0, -5), (2, -5),
    (0, -4), (3, -4),
    (-3, -3), (0, -3), (4, -3),
    (-2, -2), (0, -2), (3, -2),
    (-1, -1), (0, -1), (2, -1),
    (0, 0), (1, 0),
    (-1, 1), (0, 1), (2, 1),
    (-2, 2), (0, 2), (3, 2),
    (-3, 3), (0, 3), (4, 3),
    (0, 4), (3, 4),
    (0, 5), (2, 5),
    (0, 6), (1, 6),
]

def block(x, y, color, size):
    return render.Padding(
        pad = (x, y, 0, 0),
        child = render.Box(width = size, height = size, color = color),
    )

def main(config):
    width = int(config.str("width", DEFAULT_WIDTH))
    height = int(config.str("height", DEFAULT_HEIGHT))

    frames = create_setup_animation(width, height)

    return render.Root(
        delay = 50,  # ~20fps, matches the original spinner speed
        child = render.Animation(
            children = frames,
        ),
    )

def create_setup_animation(width, height):
    """QR code on the left, bluetooth + rotating spinner on the right"""
    frames = []
    num_frames = len(SPINNER_PATH_RELATIVE)

    # Double the QR modules when there's room (e.g. 128x64)
    qr_scale = 2 if width - QR_MODULES * 2 >= 34 and height >= QR_MODULES * 2 + 2 else 1
    qr_size = QR_MODULES * qr_scale
    qr_x = 2
    qr_y = (height - qr_size) // 2

    qr_image = qrcode.generate(
        url = SETUP_URL,
        size = "medium",
        color = "#ffffff",
        background = "#000000",
    )

    qr_element = render.Padding(
        pad = (qr_x, qr_y, 0, 0),
        child = render.Image(
            src = qr_image,
            width = qr_size,
            height = qr_size,
        ),
    )

    # Bluetooth + spinner centered in the space right of the QR;
    # the spinner orbit spans about 21px, so scale it up only when
    # both dimensions have room
    right_start = qr_x + qr_size + 1
    remaining = width - right_start
    bt_scale = 2 if remaining >= 44 and height >= 44 else 1

    bt_cx = right_start + remaining // 2 - bt_scale
    bt_cy = height // 2

    for frame_idx in range(num_frames):
        elements = [qr_element]

        for dx, dy in BT_PIXELS:
            elements.append(block(bt_cx + dx * bt_scale, bt_cy + dy * bt_scale, BT_COLOR, bt_scale))

        # Spinner: bright head with a fading 4-pixel tail
        for tail_idx in range(5):
            pos_idx = (frame_idx - tail_idx) % num_frames
            dx, dy = SPINNER_PATH_RELATIVE[pos_idx]
            elements.append(block(bt_cx + dx * bt_scale, bt_cy + dy * bt_scale, SPINNER_COLORS[tail_idx], bt_scale))

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
