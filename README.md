# Audio Tools

My scripts and documentation for automating encoding and tagging of audio files.

## Encoding

I use the following open source codecs for encoding my audio files:

- **FLAC**: I encode to FLAC for reference quality playback and storage on my personal computer.
- **Opus**: I encode to Ogg Opus for high quality playback on portable devices, for example modern Android devices.
- **Vorbis**: I encode to Ogg Vorbis for high quality playback on legacy devices, for example older MP3 players or car head units.

## Tagging

I use MusicBrainz Picard for tagging my FLAC files. My settings and procedures are documented in [`docs/picard.md`](docs/picard.md).

## Prerequisites

To work with this repository, you'll need to download and install the following tools:

- FLAC
- Opus Tools
- Vorbis Tools
- MusicBrainz Picard

You'll also need to set the following environment variables:

- `FLAC_DIR`: the absolute path of the directory containing your FLAC files.
- `OPUS_DIR` _(optional)_: the absolute path of the directory that should contain your Ogg Opus files.
- `OGG_DIR` _(optional)_: the absolute path of the directory that should contain your Ogg Vorbis files.

For example, add the following to your `.bash_profile`:

```bash
export FLAC_DIR="$HOME/Music/FLAC"
export OPUS_DIR="$HOME/Music/Ogg Opus"
export OGG_DIR="$HOME/Music/Ogg Vorbis"
```
