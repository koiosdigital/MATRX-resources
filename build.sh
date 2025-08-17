#!/bin/bash

# Check if pixlet is installed, and install it if not
if ! command -v pixlet &> /dev/null; then
    echo "pixlet not found. Installing latest version..."
    
    # Get the latest release version
    LATEST_VERSION=$(curl -s https://api.github.com/repos/tidbyt/pixlet/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4)
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "Failed to get latest version. Using fallback version v0.34.0"
        LATEST_VERSION="v0.34.0"
    fi
    
    echo "Installing pixlet $LATEST_VERSION..."
    
    # Download the archive
    curl -LO "https://github.com/tidbyt/pixlet/releases/download/$LATEST_VERSION/pixlet_${LATEST_VERSION#v}_linux_amd64.tar.gz"
    
    # Unpack the archive
    tar -xzf "pixlet_${LATEST_VERSION#v}_linux_amd64.tar.gz"
    
    # Ensure the binary is executable
    chmod +x ./pixlet
    
    # Move the binary into your path
    sudo mv pixlet /usr/local/bin/pixlet
    
    # Clean up the downloaded archive
    rm -f "pixlet_${LATEST_VERSION#v}_linux_amd64.tar.gz"
    
    echo "pixlet $LATEST_VERSION installed successfully!"
else
    echo "pixlet is already installed: $(pixlet version)"
fi

# Define the source directory and output dimensions
SOURCE_DIR="sources"
OUTPUT_DIR="./output"
DIMENSIONS=("64x32" "64x64" "128x64")

# Function to convert image to C array
convert_to_c_array() {
    local input_file="$1"
    local output_name="$2"
    
    # Convert binary data to C array format directly from WebP file
    xxd -i "$input_file" | sed "s/unsigned char.*\[\]/static const uint8_t ${output_name}_data[]/" | sed "s/unsigned int.*=/static const size_t ${output_name}_size =/"
}

# Function to generate header file
generate_header_file() {
    local width="$1"
    local height="$2"
    local output_dir="$3"
    local header_file="$output_dir/${width}x${height}_static.h"
    
    echo "Generating header file: $header_file"
    
    # Start header file
    cat > "$header_file" << EOF
#ifndef STATIC_RESOURCES_H
#define STATIC_RESOURCES_H

#include <stdint.h>
#include <stddef.h>
#include <string.h>

// Image dimensions
#define IMAGE_WIDTH_${width}X${height} ${width}
#define IMAGE_HEIGHT_${width}X${height} ${height}
#define IMAGE_BYTES_PER_PIXEL 3

EOF

    # Add image data arrays
    for webp_file in "$output_dir/${width}x${height}"/*.webp; do
        if [ -f "$webp_file" ]; then
            basename_no_ext=$(basename "$webp_file" .webp)
            echo "// Image data for $basename_no_ext" >> "$header_file"
            convert_to_c_array "$webp_file" "$basename_no_ext" >> "$header_file"
            echo "" >> "$header_file"
        fi
    done
    
    # Add function declarations and implementations
    cat >> "$header_file" << EOF
// Structure to hold image information
typedef struct {
    const char* name;
    const uint8_t* data;
    size_t size;
} image_info_t;

// Array of available images
static const image_info_t available_images[] = {
EOF

    # Add image entries
    for webp_file in "$output_dir/${width}x${height}"/*.webp; do
        if [ -f "$webp_file" ]; then
            basename_no_ext=$(basename "$webp_file" .webp)
            echo "    {\"$basename_no_ext\", ${basename_no_ext}_data, ${basename_no_ext}_size}," >> "$header_file"
        fi
    done
    
    cat >> "$header_file" << EOF
};

static const size_t num_available_images = sizeof(available_images) / sizeof(available_images[0]);

/**
 * Get image data by name
 * @param name The name of the image (without extension)
 * @param data Pointer to store the image data pointer (output)
 * @param size Pointer to store the image data size (output)
 * @return 1 if image found, 0 if not found
 */
static inline int get_image_data(const char* name, const uint8_t** data, size_t* size) {
    if (!name || !data || !size) {
        return 0;
    }
    
    for (size_t i = 0; i < num_available_images; i++) {
        if (strcmp(available_images[i].name, name) == 0) {
            *data = available_images[i].data;
            *size = available_images[i].size;
            return 1;
        }
    }
    
    // Image not found
    *data = NULL;
    *size = 0;
    return 0;
}

/**
 * Get image dimensions
 * @param width Pointer to store image width (output)
 * @param height Pointer to store image height (output)
 */
static inline void get_image_dimensions(int* width, int* height) {
    if (width) *width = IMAGE_WIDTH_${width}X${height};
    if (height) *height = IMAGE_HEIGHT_${width}X${height};
}

/**
 * List available image names
 * @param names Array to store image name pointers (output)
 * @param max_names Maximum number of names to store
 * @return Number of available images
 */
static inline size_t list_available_images(const char** names, size_t max_names) {
    size_t count = (num_available_images < max_names) ? num_available_images : max_names;
    
    if (names) {
        for (size_t i = 0; i < count; i++) {
            names[i] = available_images[i].name;
        }
    }
    
    return num_available_images;
}

#endif // ${width}X${height}_STATIC_H
EOF
}

# Loop through each file in the sources directory
for FILE in "$SOURCE_DIR"/*; do
    BASENAME=$(basename "$FILE") # Extract the basename of the source file
    for DIM in "${DIMENSIONS[@]}"; do
        echo "Processing $FILE for dimension $DIM"
        # Extract width and height from the dimension
        WIDTH=$(echo "$DIM" | cut -dx -f1)
        HEIGHT=$(echo "$DIM" | cut -dx -f2)
        
        mkdir -p "$OUTPUT_DIR/${WIDTH}x${HEIGHT}" # Create the output directory if it doesn't exist

        # Define the output file name
        OUTPUT_FILE="$OUTPUT_DIR/${WIDTH}x${HEIGHT}/${BASENAME%.*}.webp"
        
        # Run the pixlet render command
        pixlet render "$FILE" width="$WIDTH" height="$HEIGHT" --height "$HEIGHT" --width "$WIDTH" -o "$OUTPUT_FILE"
    done
done

# Generate C header files for each dimension
for DIM in "${DIMENSIONS[@]}"; do
    WIDTH=$(echo "$DIM" | cut -dx -f1)
    HEIGHT=$(echo "$DIM" | cut -dx -f2)
    generate_header_file "$WIDTH" "$HEIGHT" "$OUTPUT_DIR"
done

echo "Build completed! Generated WebP files and C header files."