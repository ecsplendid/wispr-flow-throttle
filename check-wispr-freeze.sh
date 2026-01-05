#!/bin/bash
# Check if Wispr Flow should be throttled based on last use time
# Also checks Wispr Flow logs for recent transcription activity

TIMEOUT_MINUTES=${WISPR_TIMEOUT:-5}
TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))
TIMESTAMP_FILE=~/.wispr_last_use
FROZEN_MARKER=~/.wispr_frozen
WISPR_LOG=~/Library/Logs/"Wispr Flow"/main.log

# Function to check if there was a recent transcription in Wispr logs
check_recent_transcription() {
    if [[ ! -f "$WISPR_LOG" ]]; then
        return 1
    fi
    
    local now=$(date +%s)
    local cutoff=$((now - TIMEOUT_SECONDS))
    
    # Get recent dictation events
    while IFS= read -r line; do
        if [[ $line =~ ^\[([0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
            local log_time="${BASH_REMATCH[1]}"
            local log_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S" "$log_time" +%s 2>/dev/null)
            if [[ -n "$log_epoch" && $log_epoch -gt $cutoff ]]; then
                return 0  # Recent activity found
            fi
        fi
    done < <(grep -E "dictation stop|paste outcome.*success=true" "$WISPR_LOG" 2>/dev/null | tail -10)
    
    return 1
}

# Function to throttle Wispr Flow via App Tamer
freeze_wispr() {
    if [[ ! -f "$FROZEN_MARKER" ]]; then
        # Freeze main app
        defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow" -dict-add pauseInBackground -int 1 limitInBackground -int 0
        # Freeze accessibility helper
        defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow.accessibility-mac-app" -dict-add pauseInBackground -int 1 limitInBackground -int 0
        
        osascript -e 'tell application "App Tamer" to quit' 2>/dev/null
        sleep 0.5
        open -a "App Tamer"
        
        touch "$FROZEN_MARKER"
        osascript -e 'display notification "Wispr Flow throttled. Type uw in Spotlight to wake." with title "Wispr Flow Throttled"' 2>/dev/null
    fi
}

# If no timestamp file exists
if [[ ! -f "$TIMESTAMP_FILE" ]]; then
    if check_recent_transcription; then
        date +%s > "$TIMESTAMP_FILE"
        exit 0
    fi
    freeze_wispr
    exit 0
fi

LAST_USE=$(cat "$TIMESTAMP_FILE")
NOW=$(date +%s)
ELAPSED=$((NOW - LAST_USE))

if [[ $ELAPSED -gt $TIMEOUT_SECONDS ]]; then
    if check_recent_transcription; then
        date +%s > "$TIMESTAMP_FILE"
        exit 0
    fi
    freeze_wispr
    rm -f "$TIMESTAMP_FILE"
fi
