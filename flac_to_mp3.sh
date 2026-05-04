#!/usr/bin/env bash
# flac_to_mp3.sh
SOURCE_DIR="${1%/}"
DEST_DIR="${2%/}"

if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg is not installed." >&2
    exit 1
fi

if ! command -v rsync &>/dev/null; then
    echo "Error: rsync is not installed." >&2
    exit 1
fi

export SOURCE_DIR DEST_DIR

convert_file() {
    flac_file="$1"
    relative="${flac_file#"$SOURCE_DIR"/}"
    mp3_file="$DEST_DIR/${relative%.flac}.mp3"

    mkdir -p "$(dirname "$mp3_file")"

    if [[ -f "$mp3_file" ]]; then
        echo "Skipping (exists): $mp3_file"
        return
    fi

    echo "Converting: $relative"
    ffmpeg -nostdin \
        -i "$flac_file" \
        -codec:a libmp3lame \
        -b:a 320k \
        -map_metadata 0 \
        -id3v2_version 3 \
        -y \
        "$mp3_file" \
        -loglevel error

    if [[ $? -eq 0 ]]; then
        echo "  Done: $mp3_file"
    else
        echo "  FAILED: $flac_file" >&2
    fi
}

copy_file() {
    other_file="$1"
    relative="${other_file#"$SOURCE_DIR"/}"
    dest_file="$DEST_DIR/$relative"

    mkdir -p "$(dirname "$dest_file")"

    if [[ -f "$dest_file" ]]; then
        echo "Skipping (exists): $dest_file"
        return
    fi

    echo "Copying: $relative"
    rsync -a --ignore-existing "$other_file" "$dest_file"
}

export -f convert_file copy_file

# Convert FLAC files in parallel
find "$SOURCE_DIR" -type f -name "*.flac" -print0 \
    | xargs -0 -P "$(nproc)" -I {} bash -c 'convert_file "$@"' _ {}

# Copy non-FLAC files in parallel
find "$SOURCE_DIR" -type f ! -name "*.flac" -print0 \
    | xargs -0 -P "$(nproc)" -I {} bash -c 'copy_file "$@"' _ {}

# Rename folders: remove " [FLAC]" and " FLAC" from directory names
find "$DEST_DIR" -depth -type d | while IFS= read -r dir; do
    parent="$(dirname "$dir")"
    base="$(basename "$dir")"
    newbase="${base/ \[FLAC\]/}"
    newbase="${newbase/ FLAC/}"
    if [[ "$newbase" != "$base" ]]; then
        mv -- "$dir" "$parent/$newbase"
        echo "Renamed: $base → $newbase"
    fi
done

echo "Conversion complete."
