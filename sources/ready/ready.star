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
    # Seed the random generator for deterministic cloud shapes
    random.seed(seed)
    
    # Create base cloud pattern using noise-like generation
    pattern = []
    
    # Use seed to create deterministic but varied shapes
    center_x = math.floor(width / 2)
    center_y = math.floor(height / 2)
    
    for y in range(height):
        row = []
        for x in range(width):
            # Calculate distance from center
            dx = x - center_x
            dy = y - center_y
            dist_sq = dx * dx + dy * dy
            max_dist_sq = int(math.pow(min(width, height) / 2, 2))
            
            # Create organic cloud boundary using random noise
            noise = random.number(0, 100)
            
            # Probability decreases with distance from center
            base_prob = max(0, 100 - math.floor((dist_sq * 100) / max_dist_sq))
            
            # Add noise to create irregular edges
            final_prob = base_prob + math.floor((noise - 50) / 3)
            
            # Add some vertical stretching for cloud-like appearance
            if abs(dy) < math.floor(height / 4):
                final_prob += 20
            
            # Determine if this pixel is part of the cloud
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
    
    # Create cloud animation frames
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
    
    # Cloud particle system - multiple layers of drifting clouds
    num_frames = 60  # 60 frames for smooth loop
    
    # Generate random cloud instances for each layer
    num_layers = 3
    cloud_instances = []
    
    for layer_idx in range(num_layers):
        layer_clouds = []
        # Seed for each layer to get consistent but varied results
        random.seed(layer_idx * 100)
        num_clouds_in_layer = random.number(2, 4)
        
        for cloud_idx in range(num_clouds_in_layer):
            seed = layer_idx * 1000 + cloud_idx * 100
            
            # Seed for this specific cloud
            random.seed(seed)
            
            # Random size (reasonable bounds)
            cloud_width = random.number(14, 45)
            cloud_height = random.number(15, 30)
            
            # Random position distributed across entire screen
            # X position can go beyond screen for smooth scrolling effect
            start_x = random.number(0, width + 40) - 20  # Allow clouds to start off-screen
            
            # Y position distributed evenly across entire screen height
            # Account for cloud height to ensure clouds don't get cut off
            max_y = max(0, height - cloud_height)
            start_y = random.number(0, max_y)
            
            # Random speed and opacity
            speed = random.number(20, 80) / 100.0  # 0.2 to 0.8
            opacity = random.number(40, 80) / 100.0  # 0.4 to 0.8
            
            # Generate algorithmic cloud shape
            cloud_pattern = generate_cloud_shape(cloud_width, cloud_height, seed)
            
            # Base color varies by layer
            base_color = 140 + layer_idx * 30
            
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
        
        # Background gradient (dark to light blue simulating sky)
        cloud_elements.append(
            render.Box(
                width = width,
                height = height,
                color = "#1a1a2e",  # Dark blue background
            )
        )
        
        # Generate multiple cloud layers
        for layer_idx, layer_clouds in enumerate(cloud_instances):
            for cloud in layer_clouds:
                clouds = create_moving_cloud(width, height, frame_idx, cloud)
                cloud_elements.extend(clouds)
        
        # Add "ready" text with fade effect
        text_alpha = (math.sin(frame_idx * 0.2) + 1) / 2  # Slow pulse
        text_brightness = int(120 + 60 * text_alpha)
        hex_brightness = to_hex_string(text_brightness)
        hex_brightness_half = to_hex_string(math.floor(text_brightness/2))
        text_color = "#" + (hex_brightness_half) + hex_brightness + hex_brightness_half
        
        # Responsive font selection and accurate text centering
        text_content = "ready"
        font_name = "tom-thumb" if width < 32 or height < 32 else "6x13"
        
        # Calculate accurate text dimensions based on font
        if font_name == "tom-thumb":
            char_width = 4  # tom-thumb is approximately 4px wide per char
            text_height = 5  # tom-thumb is 5px tall
        else:
            char_width = 6  # 6x13 is 6px wide per char
            text_height = 13  # 6x13 is 13px tall
        
        text_width = len(text_content) * char_width
        
        # Center both horizontally and vertically
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
    
    # Calculate current position based on drift
    drift_offset = (frame_idx * cloud_config["speed"]) % (width + 40)
    current_x = int(cloud_config["start_x"] - drift_offset)
    current_y = cloud_config["start_y"]
    
    # Only render clouds that are visible or partially visible
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
                
                # Add subtle color variation for texture
                color_variation = int(base_color * opacity)
                color_variation += (row_idx + col_idx) % 20 - 10  # Slight texture
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