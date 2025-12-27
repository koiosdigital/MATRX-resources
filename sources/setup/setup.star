load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")

DEFAULT_WIDTH = "64"
DEFAULT_HEIGHT = "32"

# Colors from reference image
PHONE_BORDER = "#212121"  # rgb(33,33,33)
PHONE_SCREEN = "#ffffff"  # rgb(255,255,255)
APP_BG = "#1e88e5"        # rgb(30,136,229)
BT_COLOR = "#2196f3"      # rgb(33,150,243)

# Spinner gradient colors (brightness: 255, 221, 185, 149, 113)
SPINNER_COLORS = ["#ffffff", "#dddddd", "#b9b9b9", "#959595", "#717171"]

# Spinner path - 56 positions around the bluetooth symbol (clockwise)
# Relative to bluetooth center (0, 0)
SPINNER_PATH_RELATIVE = [
    (10, 0), (10, 1), (10, 2), (10, 3), (9, 4), (9, 5), (8, 6), (7, 7),
    (6, 8), (5, 8), (4, 9), (3, 9), (2, 9), (1, 9), (0, 9), (-1, 9),
    (-2, 9), (-3, 9), (-4, 8), (-5, 8), (-6, 7), (-7, 6), (-8, 5), (-8, 4),
    (-9, 3), (-9, 2), (-9, 1), (-9, 0), (-9, -1), (-9, -2), (-9, -3), (-9, -4),
    (-8, -5), (-8, -6), (-7, -7), (-6, -8), (-5, -9), (-4, -9), (-3, -10), (-2, -10),
    (-1, -10), (0, -10), (1, -10), (2, -10), (3, -10), (4, -10), (5, -9), (6, -9),
    (7, -8), (8, -7), (9, -6), (9, -5), (10, -4), (10, -3), (10, -2), (10, -1),
]

# Reference dimensions (64x32)
REF_WIDTH = 64
REF_HEIGHT = 32

# Content bounds in reference (for centering calculation)
# Phone at x=7, bt center at x=47, total content from x=7 to x=57 = 51 wide
# Content from y=1 to y=30 = 30 tall
CONTENT_WIDTH = 51
CONTENT_HEIGHT = 30
CONTENT_START_X = 7  # Where phone starts in reference
CONTENT_START_Y = 1  # Where content starts in reference

def main(config):
    width = int(config.str("width", DEFAULT_WIDTH))
    height = int(config.str("height", DEFAULT_HEIGHT))

    # Create animated frames with spinner
    frames = create_setup_animation(width, height)

    return render.Root(
        delay = 50,  # ~20fps to match reference animation speed
        child = render.Animation(
            children = frames,
        ),
    )

def create_setup_animation(width, height):
    """Creates animation with rotating spinner around bluetooth symbol"""
    frames = []
    num_frames = 56  # Match reference animation

    # Calculate offset to center the content
    offset_x = (width - CONTENT_WIDTH) // 2 - CONTENT_START_X
    offset_y = (height - CONTENT_HEIGHT) // 2 - CONTENT_START_Y

    # Phone position (reference: x=7, y=1)
    phone_x = 7 + offset_x
    phone_y = 1 + offset_y

    # Bluetooth symbol center (reference: x=47, y=16)
    bt_cx = 47 + offset_x
    bt_cy = 16 + offset_y

    for frame_idx in range(num_frames):
        elements = []

        # Phone icon
        elements.extend(create_phone_icon(phone_x, phone_y))

        # Bluetooth symbol
        elements.extend(create_bluetooth_symbol(bt_cx, bt_cy))

        # Rotating spinner
        elements.extend(create_spinner(frame_idx, bt_cx, bt_cy))

        frame = render.Stack(children = elements)
        frames.append(frame)

    return frames

def create_spinner(frame_idx, bt_cx, bt_cy):
    """Create the 5-pixel gradient spinner at current rotation position"""
    elements = []

    # Get positions for the 5 spinner pixels (head + 4 trailing)
    num_positions = len(SPINNER_PATH_RELATIVE)

    for i in range(5):
        # Get position index (wrapping around)
        pos_idx = (frame_idx - i) % num_positions
        dx, dy = SPINNER_PATH_RELATIVE[pos_idx]

        # Apply offset from bluetooth center
        x = bt_cx + dx
        y = bt_cy + dy

        # Color gradient: brightest at head, dimmer toward tail
        color = SPINNER_COLORS[i]

        elements.append(create_pixel(x, y, color))

    return elements

def create_phone_icon(x, y):
    """Create phone icon matching ble_prov.webp exactly"""
    elements = []

    # Phone dimensions: 18 wide, 30 tall (from x=7 to x=24, y=1 to y=30)
    phone_width = 18
    phone_height = 30

    # Top rounded edge (row 1) - border only
    for px in range(x + 2, x + 2 + 14):
        elements.append(create_pixel(px, y, PHONE_BORDER))

    # Row 2 - white screen starts
    elements.append(create_pixel(x + 1, y + 1, PHONE_BORDER))
    for px in range(x + 2, x + 2 + 14):
        elements.append(create_pixel(px, y + 1, PHONE_SCREEN))
    elements.append(create_pixel(x + 16, y + 1, PHONE_BORDER))

    # Row 3 - speaker notch
    elements.append(create_pixel(x, y + 2, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 2, PHONE_SCREEN))
    for px in range(x + 2, x + 7):
        elements.append(create_pixel(px, y + 2, PHONE_SCREEN))
    for px in range(x + 7, x + 11):
        elements.append(create_pixel(px, y + 2, PHONE_BORDER))
    for px in range(x + 11, x + 16):
        elements.append(create_pixel(px, y + 2, PHONE_SCREEN))
    elements.append(create_pixel(x + 16, y + 2, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 2, PHONE_BORDER))

    # Row 4 - full white
    elements.append(create_pixel(x, y + 3, PHONE_BORDER))
    for px in range(x + 1, x + 17):
        elements.append(create_pixel(px, y + 3, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 3, PHONE_BORDER))

    # Row 5 - border around screen area starts
    elements.append(create_pixel(x, y + 4, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 4, PHONE_SCREEN))
    for px in range(x + 2, x + 16):
        elements.append(create_pixel(px, y + 4, PHONE_BORDER))
    elements.append(create_pixel(x + 16, y + 4, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 4, PHONE_BORDER))

    # Rows 6-17 - app icon area (blue background, NO white pixels inside)
    for row in range(5, 18):
        elements.append(create_pixel(x, y + row, PHONE_BORDER))
        elements.append(create_pixel(x + 1, y + row, PHONE_SCREEN))
        elements.append(create_pixel(x + 2, y + row, PHONE_BORDER))
        for px in range(x + 3, x + 15):
            elements.append(create_pixel(px, y + row, APP_BG))
        elements.append(create_pixel(x + 15, y + row, PHONE_BORDER))
        elements.append(create_pixel(x + 16, y + row, PHONE_SCREEN))
        elements.append(create_pixel(x + 17, y + row, PHONE_BORDER))

    # Rows 18-22 - bluetooth icon inside app (original has small bt icon in app)
    # Row 18 - start of bt icon box
    elements.append(create_pixel(x, y + 17, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 17, PHONE_SCREEN))
    elements.append(create_pixel(x + 2, y + 17, PHONE_BORDER))
    elements.append(create_pixel(x + 3, y + 17, APP_BG))
    for px in range(x + 4, x + 9):
        elements.append(create_pixel(px, y + 17, PHONE_BORDER))
    for px in range(x + 9, x + 15):
        elements.append(create_pixel(px, y + 17, APP_BG))
    elements.append(create_pixel(x + 15, y + 17, PHONE_BORDER))
    elements.append(create_pixel(x + 16, y + 17, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 17, PHONE_BORDER))

    # Row 19 - bt icon WWW (changed to border color, no white)
    elements.append(create_pixel(x, y + 18, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 18, PHONE_SCREEN))
    elements.append(create_pixel(x + 2, y + 18, PHONE_BORDER))
    elements.append(create_pixel(x + 3, y + 18, APP_BG))
    elements.append(create_pixel(x + 4, y + 18, PHONE_BORDER))
    for px in range(x + 5, x + 8):
        elements.append(create_pixel(px, y + 18, PHONE_BORDER))
    elements.append(create_pixel(x + 8, y + 18, PHONE_BORDER))
    for px in range(x + 9, x + 15):
        elements.append(create_pixel(px, y + 18, APP_BG))
    elements.append(create_pixel(x + 15, y + 18, PHONE_BORDER))
    elements.append(create_pixel(x + 16, y + 18, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 18, PHONE_BORDER))

    # Row 20 - bt icon W (changed to border color, no white)
    elements.append(create_pixel(x, y + 19, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 19, PHONE_SCREEN))
    elements.append(create_pixel(x + 2, y + 19, PHONE_BORDER))
    elements.append(create_pixel(x + 3, y + 19, APP_BG))
    elements.append(create_pixel(x + 4, y + 19, PHONE_BORDER))
    elements.append(create_pixel(x + 5, y + 19, PHONE_BORDER))
    elements.append(create_pixel(x + 6, y + 19, PHONE_BORDER))
    elements.append(create_pixel(x + 7, y + 19, PHONE_BORDER))
    elements.append(create_pixel(x + 8, y + 19, PHONE_BORDER))
    for px in range(x + 9, x + 15):
        elements.append(create_pixel(px, y + 19, APP_BG))
    elements.append(create_pixel(x + 15, y + 19, PHONE_BORDER))
    elements.append(create_pixel(x + 16, y + 19, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 19, PHONE_BORDER))

    # Row 21 - bt icon W (changed to border color, no white)
    elements.append(create_pixel(x, y + 20, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 20, PHONE_SCREEN))
    elements.append(create_pixel(x + 2, y + 20, PHONE_BORDER))
    elements.append(create_pixel(x + 3, y + 20, APP_BG))
    elements.append(create_pixel(x + 4, y + 20, PHONE_BORDER))
    elements.append(create_pixel(x + 5, y + 20, PHONE_BORDER))
    elements.append(create_pixel(x + 6, y + 20, PHONE_BORDER))
    elements.append(create_pixel(x + 7, y + 20, PHONE_BORDER))
    elements.append(create_pixel(x + 8, y + 20, PHONE_BORDER))
    for px in range(x + 9, x + 15):
        elements.append(create_pixel(px, y + 20, APP_BG))
    elements.append(create_pixel(x + 15, y + 20, PHONE_BORDER))
    elements.append(create_pixel(x + 16, y + 20, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 20, PHONE_BORDER))

    # Row 22 - bt icon box ends
    elements.append(create_pixel(x, y + 21, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 21, PHONE_SCREEN))
    elements.append(create_pixel(x + 2, y + 21, PHONE_BORDER))
    elements.append(create_pixel(x + 3, y + 21, APP_BG))
    for px in range(x + 4, x + 9):
        elements.append(create_pixel(px, y + 21, PHONE_BORDER))
    for px in range(x + 9, x + 15):
        elements.append(create_pixel(px, y + 21, APP_BG))
    elements.append(create_pixel(x + 15, y + 21, PHONE_BORDER))
    elements.append(create_pixel(x + 16, y + 21, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 21, PHONE_BORDER))

    # Row 23 - full blue again
    elements.append(create_pixel(x, y + 22, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 22, PHONE_SCREEN))
    elements.append(create_pixel(x + 2, y + 22, PHONE_BORDER))
    for px in range(x + 3, x + 15):
        elements.append(create_pixel(px, y + 22, APP_BG))
    elements.append(create_pixel(x + 15, y + 22, PHONE_BORDER))
    elements.append(create_pixel(x + 16, y + 22, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 22, PHONE_BORDER))

    # Row 24 - border around screen area ends
    elements.append(create_pixel(x, y + 23, PHONE_BORDER))
    elements.append(create_pixel(x + 1, y + 23, PHONE_SCREEN))
    for px in range(x + 2, x + 16):
        elements.append(create_pixel(px, y + 23, PHONE_BORDER))
    elements.append(create_pixel(x + 16, y + 23, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 23, PHONE_BORDER))

    # Row 25 - full white
    elements.append(create_pixel(x, y + 24, PHONE_BORDER))
    for px in range(x + 1, x + 17):
        elements.append(create_pixel(px, y + 24, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 24, PHONE_BORDER))

    # Row 26 - home button area
    elements.append(create_pixel(x, y + 25, PHONE_BORDER))
    for px in range(x + 1, x + 8):
        elements.append(create_pixel(px, y + 25, PHONE_SCREEN))
    elements.append(create_pixel(x + 8, y + 25, PHONE_BORDER))
    elements.append(create_pixel(x + 9, y + 25, PHONE_BORDER))
    for px in range(x + 10, x + 17):
        elements.append(create_pixel(px, y + 25, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 25, PHONE_BORDER))

    # Row 27 - home button
    elements.append(create_pixel(x, y + 26, PHONE_BORDER))
    for px in range(x + 1, x + 7):
        elements.append(create_pixel(px, y + 26, PHONE_SCREEN))
    elements.append(create_pixel(x + 7, y + 26, PHONE_BORDER))
    elements.append(create_pixel(x + 8, y + 26, PHONE_SCREEN))
    elements.append(create_pixel(x + 9, y + 26, PHONE_SCREEN))
    elements.append(create_pixel(x + 10, y + 26, PHONE_BORDER))
    for px in range(x + 11, x + 17):
        elements.append(create_pixel(px, y + 26, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 26, PHONE_BORDER))

    # Row 28 - home button
    elements.append(create_pixel(x, y + 27, PHONE_BORDER))
    for px in range(x + 1, x + 8):
        elements.append(create_pixel(px, y + 27, PHONE_SCREEN))
    elements.append(create_pixel(x + 8, y + 27, PHONE_BORDER))
    elements.append(create_pixel(x + 9, y + 27, PHONE_BORDER))
    for px in range(x + 10, x + 17):
        elements.append(create_pixel(px, y + 27, PHONE_SCREEN))
    elements.append(create_pixel(x + 17, y + 27, PHONE_BORDER))

    # Row 29 - bottom rounded edge starts
    elements.append(create_pixel(x + 1, y + 28, PHONE_BORDER))
    for px in range(x + 2, x + 16):
        elements.append(create_pixel(px, y + 28, PHONE_SCREEN))
    elements.append(create_pixel(x + 16, y + 28, PHONE_BORDER))

    # Row 30 - bottom border
    for px in range(x + 2, x + 16):
        elements.append(create_pixel(px, y + 29, PHONE_BORDER))

    return elements

def create_bluetooth_symbol(cx, cy):
    """Create bluetooth symbol at center position matching ble_prov.webp exactly"""
    elements = []

    # Exact pixel positions relative to center
    bt_pixels = [
        (0, -6), (1, -6),      # top
        (0, -5), (2, -5),
        (0, -4), (3, -4),
        (-3, -3), (0, -3), (4, -3),
        (-2, -2), (0, -2), (3, -2),
        (-1, -1), (0, -1), (2, -1),
        (0, 0), (1, 0),        # center
        (-1, 1), (0, 1), (2, 1),
        (-2, 2), (0, 2), (3, 2),
        (-3, 3), (0, 3), (4, 3),
        (0, 4), (3, 4),
        (0, 5), (2, 5),
        (0, 6), (1, 6),        # bottom
    ]

    for dx, dy in bt_pixels:
        elements.append(create_pixel(cx + dx, cy + dy, BT_COLOR))

    return elements

def create_pixel(x, y, color):
    """Create a single pixel at position"""
    return render.Padding(
        pad = (x, y, 0, 0),
        child = render.Box(
            width = 1,
            height = 1,
            color = color,
        ),
    )

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
