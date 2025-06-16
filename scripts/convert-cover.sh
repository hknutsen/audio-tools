#! /bin/bash

# Converts all "cover.jpg" files in the source directory to "cover_600.jpg"
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
  # Resize input image to 600x600 pixels.
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

  # By default, the ImageMagick convert tool estimates an appropriate quality
  # level based on the input image. If an estimate cannot be made, quality is
  # set to 92 instead. We want a consistent quality level for all album covers,
  # so we explicitly set the quality to 92.
  # Ref: https://www.imagemagick.org/script/command-line-options.php#quality
  magick "$input_file" -resize 600x600 -quality 92 "$output_file"

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
  | sort | parallel --progress 'resize_image {} {.}_600.jpg'
