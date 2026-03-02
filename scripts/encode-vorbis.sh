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

  oggenc -q 6 --resample 44100 --output "$ogg_file" --quiet "$flac_file"
  realpath "$ogg_file"
  
  # Cover art has to be exported from the PICTURE blocks in the FLAC file, then
  # base64 encoded and embedded in the Ogg Vorbis file in
  # "METADATA_BLOCK_PICTURE" tags.
  # Ref: https://wiki.xiph.org/index.php/VorbisComment#Cover_art
  number_of_blocks=$(metaflac --list "$flac_file" \
    | grep -E -c "^METADATA block #[0-9]+$")

  # Block 0 is the mandatory STREAMINFO block and can be skipped.
  for (( n = 1; n < "$number_of_blocks"; n++ )) do

    # If block n is a PICTURE block, return and base64 encode the binary data.
    picture=$(metaflac --list --block-number="$n" --block-type=PICTURE \
      --data-format=binary-headerless "$flac_file" | base64 --wrap 0)

    if [[ -n "$picture" ]]; then
      echo "METADATA_BLOCK_PICTURE=$picture" \
        | vorbiscomment --append "$ogg_file"
    fi
  done
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
