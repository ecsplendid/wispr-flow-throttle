#!/bin/bash
# Check if Wispr Flow should be throttled based on last use time

TIMEOUT_MINUTES=${WISPR_TIMEOUT:-5}
TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))
TIMESTAMP_FILE=~/.wispr_last_use
FROZEN_MARKER=~/.wispr_frozen

# Function to throttle Wispr Flow via App Tamer preferences
# Note: AppleScript 'manage' command has a bug - it returns true but doesn't modify settings
# So we use defaults write directly
freeze_wispr() {
    # Only notify if not already frozen
    if [[ ! -f "$FROZEN_MARKER" ]]; then
        # Set App Tamer to stop Wispr Flow completely (not just slow)
        defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow" -dict-add pauseInBackground -int 1 limitInBackground -int 0
        # Restart App Tamer to pick up the changes
        osascript -e 'tell application "App Tamer" to quit' 2>/dev/null
        sleep 0.5
        open -a "App Tamer"

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
