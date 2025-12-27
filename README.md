# MATRX Resources

A build system for converting [Pixlet](https://github.com/tidbyt/pixlet) applets into embeddable C header files for MATRX embedded display systems.

## Overview

This project takes Pixlet `.star` applet source files and generates WebP animations at multiple resolutions, then converts them into C header files with embedded binary data. This allows embedded systems to display animations without requiring runtime file system access.

## Features

- Renders Pixlet applets at multiple resolutions (64x32, 64x64, 128x64)
- Automatically installs Pixlet if not present
- Generates C header files with embedded WebP data
- Provides convenient C API for accessing image resources by name
- Zero-dependency static headers (no external files needed)

## Project Structure

```
MATRX-resources/
├── sources/           # Pixlet .star source files
│   ├── boot/
│   ├── check_updates/
│   ├── connecting_cloud/
│   ├── connecting_wifi/
│   ├── factory_reset_hold/
│   ├── factory_reset_success/
│   ├── keygen/
│   ├── ready/
│   └── setup/
├── output/            # Generated files
│   ├── 64x32/        # 64x32 WebP files
│   ├── 64x64/        # 64x64 WebP files
│   ├── 128x64/       # 128x64 WebP files
│   ├── 64x32_static.h
│   ├── 64x64_static.h
│   └── 128x64_static.h
└── build.sh          # Build script
```

## Requirements

- Bash
- curl
- xxd
- sed
- Pixlet (automatically installed by build script if not present)

## Usage

### Building Resources

Run the build script to process all Pixlet applets:

```bash
./build.sh
```

This will:
1. Check for Pixlet installation (install if missing)
2. Render each `.star` file at all supported resolutions
3. Generate WebP animation files
4. Create C header files with embedded data

### Using Generated Headers

Include the appropriate header file in your C/C++ project:

```c
#include "64x32_static.h"

// Get image data by name
const uint8_t* data;
size_t size;
if (get_image_data("boot", &data, &size)) {
    // Use the WebP data
    display_webp(data, size);
}

// Get dimensions
int width, height;
get_image_dimensions(&width, &height);

// List available images
const char* names[32];
size_t count = list_available_images(names, 32);
for (size_t i = 0; i < count; i++) {
    printf("Available: %s\n", names[i]);
}
```

## Available Applets

- `boot` - Boot animation
- `check_updates` - Update checking indicator
- `connecting_cloud` - Cloud connection animation
- `connecting_wifi` - WiFi connection animation
- `factory_reset_hold` - Factory reset hold indicator
- `factory_reset_success` - Factory reset success animation
- `keygen` - Key generation animation
- `pinned` - Pinned state with pushpin down
- `ready` - Ready state indicator
- `setup` - Setup mode animation
- `unpinned` - Unpinned state with pushpin up

## Adding New Applets

1. Create a new directory in `sources/` with your applet name
2. Add a `.star` file with your Pixlet code
3. Run `./build.sh` to generate resources

Example Pixlet applet:

```starlark
load("render.star", "render")

def main(config):
    return render.Root(
        child = render.Text("Hello MATRX!")
    )
```

## Output Files

### WebP Files
Generated animations in WebP format for each resolution.

### Header Files
Each resolution gets a header file (`{width}x{height}_static.h`) containing:
- Image data as byte arrays
- Image metadata (size, dimensions)
- Helper functions for accessing resources
- Complete image registry

## API Reference

### Functions

```c
// Get image data by name
int get_image_data(const char* name, const uint8_t** data, size_t* size);

// Get image dimensions for this resolution
void get_image_dimensions(int* width, int* height);

// List all available image names
size_t list_available_images(const char** names, size_t max_names);
```

### Structures

```c
typedef struct {
    const char* name;      // Image name (without .webp extension)
    const uint8_t* data;   // WebP binary data
    size_t size;           // Size of data in bytes
} image_info_t;
```

## License

See [LICENSE.txt](LICENSE.txt)

## Related Projects

- [Pixlet](https://github.com/tidbyt/pixlet) - App runtime and UX toolkit for constrained displays
- [Tidbyt](https://tidbyt.com/) - Smart display that inspired Pixlet
