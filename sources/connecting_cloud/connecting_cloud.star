load("render.star", "render")
load("schema.star", "schema")
load("math.star", "math")
load("random.star", "random")

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

def generate_cloud_shape(width, height, seed):
    """Algorithmically generate a cloud shape"""
    random.seed(seed)

    pattern = []

    center_x = math.floor(width / 2)
    center_y = math.floor(height / 2)

    for y in range(height):
        row = []
        for x in range(width):
            dx = x - center_x
            dy = y - center_y
            dist_sq = dx * dx + dy * dy
            max_dist_sq = int(math.pow(min(width, height) / 2, 2))

            noise = random.number(0, 100)

            base_prob = max(0, 100 - math.floor((dist_sq * 100) / max_dist_sq))

            final_prob = base_prob + math.floor((noise - 50) / 3)

            if abs(dy) < math.floor(height / 4):
                final_prob += 20

            threshold = random.number(30, 70)

            if final_prob > threshold:
                row.append(1)
            else:
                row.append(0)

        pattern.append(row)

    return pattern

def main(config):
    width = int(config.str("width", DEFAULT_WIDTH))
    height = int(config.str("height", DEFAULT_HEIGHT))

    cloud_frames = create_cloud_animation(width, height)

    return render.Root(
        delay = 120,  # 120ms per frame for smooth cloud drift
        child = render.Animation(
            children = cloud_frames,
        ),
    )

def create_cloud_animation(width, height):
    """Creates retro 8-bit style cloud animation for 'connecting to cloud'"""
    frames = []

    num_frames = 60

    num_layers = 3
    cloud_instances = []

    for layer_idx in range(num_layers):
        layer_clouds = []
        random.seed(layer_idx * 100)
        num_clouds_in_layer = random.number(2, 4)

        for cloud_idx in range(num_clouds_in_layer):
            seed = layer_idx * 1000 + cloud_idx * 100

            random.seed(seed)

            cloud_width = random.number(14, 45)
            cloud_height = random.number(15, 30)

            start_x = random.number(0, width + 40) - 20

            max_y = max(0, height - cloud_height)
            start_y = random.number(0, max_y)

            speed = random.number(20, 80) / 100.0
            opacity = random.number(40, 80) / 100.0

            cloud_pattern = generate_cloud_shape(cloud_width, cloud_height, seed)

            base_color = 80 + layer_idx * 20

            cloud_instance = {
                "start_x": start_x,
                "start_y": start_y,
                "speed": speed,
                "opacity": opacity,
                "pattern": cloud_pattern,
                "base_color": base_color,
            }

            layer_clouds.append(cloud_instance)

        cloud_instances.append(layer_clouds)

    for frame_idx in range(num_frames):
        cloud_elements = []

        cloud_elements.append(
            render.Box(
                width = width,
                height = height,
                color = "#0a0a1a",
            )
        )

        for layer_idx, layer_clouds in enumerate(cloud_instances):
            for cloud in layer_clouds:
                clouds = create_moving_cloud(width, height, frame_idx, cloud)
                cloud_elements.extend(clouds)

        text_brightness = 255
        text_color = "#ffffff"

        # Choose font based on screen size
        font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
        char_width = 4 if font_name == "tom-thumb" else 6
        text_height = 5 if font_name == "tom-thumb" else 13

        # Cycle ellipsis every 20 frames
        ellipsis_count = (frame_idx // 20) % 4  # 0, 1, 2, 3
        text_content = "connecting" + ("." * ellipsis_count)
        text_width = len(text_content) * char_width
        text_x = max(0, math.floor((width - text_width) / 2))
        text_y = max(0, math.floor((height - text_height) / 2))

        cloud_elements.append(
            render.Padding(
                pad = (text_x, text_y, 0, 0),
                child = render.Text(
                    content = text_content,
                    color = text_color,
                    font = font_name
                ),
            )
        )

        frame = render.Stack(children = cloud_elements)
        frames.append(frame)

    return frames

def create_moving_cloud(width, height, frame_idx, cloud_config):
    """Creates a single moving cloud instance"""
    clouds = []

    drift_offset = (frame_idx * cloud_config["speed"]) % (width + 40)
    current_x = int(cloud_config["start_x"] - drift_offset)
    current_y = cloud_config["start_y"]

    if current_x > -20 and current_x < width + 10:
        cloud_pixels = create_cloud_pixels(
            current_x,
            current_y,
            cloud_config["pattern"],
            cloud_config["base_color"],
            cloud_config["opacity"]
        )
        clouds.extend(cloud_pixels)

    return clouds

def create_cloud_pixels(start_x, start_y, pattern, base_color, opacity):
    """Creates individual pixels for a cloud shape"""
    pixels = []

    for row_idx, row in enumerate(pattern):
        for col_idx, pixel in enumerate(row):
            if pixel == 1:
                x = start_x + col_idx
                y = start_y + row_idx

                color_variation = int(base_color * opacity)
                color_variation += (row_idx + col_idx) % 20 - 10
                color_variation = max(0, min(255, color_variation))

                hex_r = to_hex_string(color_variation)
                hex_g = to_hex_string(color_variation)
                hex_b = to_hex_string(min(255, color_variation + 10))
                pixel_color = "#" + hex_r + hex_g + hex_b

                pixels.append(
                    render.Padding(
                        pad = (x, y, 0, 0),
                        child = render.Box(
                            width = 1,
                            height = 1,
                            color = pixel_color,
                        ),
                    )
                )

    return pixels

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
