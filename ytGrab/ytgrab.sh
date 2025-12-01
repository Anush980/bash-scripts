#!/bin/bash

# Interactive YouTube downloader using yt-dlp

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null
then
    echo "yt-dlp is not installed. Please install it first."
    exit 1
fi

# Ask for YouTube URL
read -p "Enter YouTube URL: " URL
if [ -z "$URL" ]; then
    echo "No URL provided. Exiting."
    exit 1
fi

# Detect if URL is a playlist
if [[ "$URL" =~ "list=" ]]; then
    read -p "This is a playlist. How many videos to download? (Press Enter for all): " PL_COUNT
    PL_ARG=""
    if [ -n "$PL_COUNT" ]; then
        PL_ARG="--playlist-items 1-$PL_COUNT"
    fi
else
    PL_ARG=""
fi

# Ask if user wants audio or video
echo "Select download type:"
select TYPE in "Video" "Audio"; do
    case $TYPE in
        Video) MODE="video"; break;;
        Audio) MODE="audio"; break;;
        *) echo "Please select 1 or 2";;
    esac
done

# Set download folder
if [ "$MODE" = "video" ]; then
    OUTPUT_DIR="/mnt/harddisk/Videos"
else
    OUTPUT_DIR="/mnt/harddisk/Music"
fi

mkdir -p "$OUTPUT_DIR"

# If video, ask for resolution
if [ "$MODE" = "video" ]; then
    echo "Fetching available formats..."
    yt-dlp -F "$URL"
    read -p "Enter format code to download (e.g., 22, 137+140): " FMT
    echo "Downloading video..."
    yt-dlp -f "$FMT" $PL_ARG -o "$OUTPUT_DIR/%(title)s.%(ext)s" "$URL" --progress-template "[%(eta)s] %(percent).1f%%"
else
    echo "Downloading audio..."
    yt-dlp -x --audio-format mp3 $PL_ARG -o "$OUTPUT_DIR/%(title)s.%(ext)s" "$URL" --progress-template "[%(eta)s] %(percent).1f%%"
fi

echo "Download finished!"
