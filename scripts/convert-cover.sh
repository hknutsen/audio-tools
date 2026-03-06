#! /bin/bash

# Converts all "cover.jpg" files in the source directory to "cover_500.jpg"
# files for embedding.
#
# Prereqs:
#   parallel
#   imagemagick
#
# Globals:
#   FLAC_DIR
#
# Usage:
#   ./convert-cover.sh

set -eu

function resize_image() {
  ##############################################################################
  # Resize input image to 500x500 pixels.
  # Arguments:
  #   Input file, a path.
  #   Output file, a path.
  # Outputs:
  #   Output file, an absolute path.
  ##############################################################################
  input_file="$1"
  output_file="$2"

  if [[ -f "$output_file" ]]; then
    # If output file already exists, skip.
    exit 0
  fi

  # Optimize image for fast loading.
  # Ref: https://www.imagemagick.org/script/command-line-options.php
  #
  # The image processing algorithm used by the resize option assumes a linear
  # colorspace. Explicitly convert to linear color (RGB) before resizing the
  # image.
  # Ref: https://imagemagick.org/script/color-management.php
  magick "$input_file" -colorspace RGB -resize 500x500 -colorspace sRGB -strip \
    -sampling-factor 4:2:0 -interlace plane -quality 90 "$output_file"

  realpath "$output_file"
}
export -f resize_image

# Ensure the input directory exists.
if [[ ! -d "$FLAC_DIR" ]]; then
  echo "Input directory '$FLAC_DIR' does not exist"
  exit 1
fi

# Convert "cover.jpg" and "cover.png" files in parallel child processes.
cd "$FLAC_DIR"
find . -name 'cover.jpg' -o -name 'cover.png' \
  | sort | parallel --progress 'resize_image {} {.}-500.jpg'
