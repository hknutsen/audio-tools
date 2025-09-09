#! /bin/bash

# Decodes audio from lossless FLAC files in the FLAC directory and encodes to
# lossy MP3 files in the MP3 directory.
#
# Prerequisites:
#   parallel
#   ffmpeg
#
# Globals:
#   FLAC_DIR
#   MP3_DIR
#
# Usage:
#   ./encode-mp3.sh

set -eu

function encode_mp3 {
  ##############################################################################
  # Decodes audio from the lossless FLAC file and encodes to a lossy MP3 file
	# in the MP3 directory.
  # Globals:
  #   MP3_DIR
  # Arguments:
  #   FLAC file, a path.
  # Outputs:
  #   MP3 file, an absolute path.
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

  mp3_file="$MP3_DIR/${flac_file%.flac}.mp3"
  if [[ -f "$mp3_file" ]]; then
    # If output MP3 file already exists, skip.
    exit 0
  fi

  dir=$(dirname "$mp3_file")
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi

  ffmpeg -loglevel error -hide_banner \
    -i "$flac_file" -codec:a libmp3lame -qscale:a 0 \
    -codec:v mjpeg -filter:v scale=300:-1 "$mp3_file"

  realpath "$mp3_file"
}
export -f encode_mp3

# Ensure the FLAC directory exists.
if [[ ! -d "$FLAC_DIR" ]]; then
  echo "FLAC directory '$FLAC_DIR' does not exist"
  exit 1
fi

# Ensure the MP3 directory exists.
if [[ ! -d "$MP3_DIR" ]]; then
  mkdir -p "$MP3_DIR"
fi

# Convert FLAC files to MP3 files in parallel child processes.
cd "$FLAC_DIR"
find . -name '*.flac' -type f | sort | parallel --progress 'encode_mp3 {}'
