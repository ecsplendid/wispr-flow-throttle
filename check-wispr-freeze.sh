#!/bin/bash
# Check if Wispr Flow should be throttled based on last use time

TIMEOUT_MINUTES=${WISPR_TIMEOUT:-5}
TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))
TIMESTAMP_FILE=~/.wispr_last_use
FROZEN_MARKER=~/.wispr_frozen

# Function to throttle Wispr Flow via App Tamer
freeze_wispr() {
    # Only notify if not already frozen
    if [[ ! -f "$FROZEN_MARKER" ]]; then
        osascript -e 'tell application "App Tamer" to manage "Wispr Flow" stop yes slow no' 2>/dev/null
        touch "$FROZEN_MARKER"
        osascript -e 'display notification "Wispr Flow throttled to save CPU. Press fn to wake." with title "Wispr Flow Throttled"' 2>/dev/null
    fi
}

# If no timestamp file, Wispr Flow should be throttled
if [[ ! -f "$TIMESTAMP_FILE" ]]; then
    freeze_wispr
    exit 0
fi

LAST_USE=$(cat "$TIMESTAMP_FILE")
NOW=$(date +%s)
ELAPSED=$((NOW - LAST_USE))

# If timeout exceeded, throttle Wispr Flow
if [[ $ELAPSED -gt $TIMEOUT_SECONDS ]]; then
    freeze_wispr
    rm -f "$TIMESTAMP_FILE"
fi
