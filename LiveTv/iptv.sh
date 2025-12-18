#!/bin/bash
# IPTV MPV Launcher Script

# The default playlist URL
PLAYLIST_URL="https://iptv-org.github.io/iptv/index.m3u"

# Check if user passed a channel number
if [ -z "$1" ]; then
    echo "No channel number provided. Playing the first channel..."
    mpv "$PLAYLIST_URL"
else
    CHANNEL_NUM=$1
    echo "Playing channel number $CHANNEL_NUM from the playlist..."
    mpv --playlist-start="$CHANNEL_NUM" "$PLAYLIST_URL"
fi
