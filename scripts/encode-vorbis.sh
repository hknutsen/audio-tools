#! /bin/bash

# Decodes audio from lossless FLAC files in the FLAC directory and encodes to
# lossy Ogg Vorbis files in the Ogg directory.
#
# Prerequisites:
#   parallel
#   vorbis-tools
#
# Globals:
#   FLAC_DIR
#   OGG_DIR
#
# Usage:
#   ./encode-vorbis.sh

set -eu

function encode_vorbis {
  ##############################################################################
  # Decodes audio from the lossless FLAC file and encodes to a lossy Ogg Vorbis
  # file in the Ogg directory.
  # Globals:
  #   OGG_DIR
  # Arguments:
  #   FLAC file, a path.
  # Outputs:
  #   Ogg Vorbis file, an absolute path.
  ##############################################################################
  flac_file="$1"
  if [[ ! -f "$flac_file" ]]; then
    echo "Input file '$flac_file' does not exist" >&2
    exit 1
  fi
  if [[ "$flac_file" != *.flac ]]; then
    echo "Input file '$flac_file' is not a FLAC file" >&2
    exit 1
  fi

  ogg_file="$OGG_DIR/${flac_file%.flac}.ogg"
  if [[ -f "$ogg_file" ]]; then
    # If output Ogg Vorbis file already exists, skip.
    exit 0
  fi

  dir=$(dirname "$ogg_file")
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi

  # Most users agree quality 5 achieves transparency if the source is lossless.
  # Ref: https://wiki.hydrogenaudio.org/index.php?title=Recommended_Ogg_Vorbis
  oggenc -q 5 -o "$ogg_file" --quiet "$flac_file"

  realpath "$ogg_file"
}
export -f encode_vorbis

# Ensure the FLAC directory exists.
if [[ ! -d "$FLAC_DIR" ]]; then
  echo "FLAC directory '$FLAC_DIR' does not exist"
  exit 1
fi

# Ensure the Ogg directory exists.
if [[ ! -d "$OGG_DIR" ]]; then
  mkdir -p "$OGG_DIR"
fi

# Convert FLAC files to Ogg Vorbis files in parallel child processes.
cd "$FLAC_DIR"
find . -name '*.flac' -type f | sort | parallel --progress 'encode_vorbis {}'
