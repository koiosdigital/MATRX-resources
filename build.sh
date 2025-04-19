#!/bin/bash

# Define the source directory and output dimensions
SOURCE_DIR="sources"
OUTPUT_DIR="./output"
DIMENSIONS=("64x32" "64x64" "128x64")

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