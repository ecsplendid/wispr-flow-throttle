#!/bin/bash
# Unfreeze Wispr Flow and its helper via App Tamer

# Unfreeze main app
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow" -dict-add pauseInBackground -int 0 limitInBackground -int 0

# Unfreeze accessibility helper (required for audio capture)
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow.accessibility-mac-app" -dict-add pauseInBackground -int 0 limitInBackground -int 0

# Wake via App Tamer
osascript -e 'tell application "App Tamer" to wake "Wispr Flow"' 2>/dev/null

# Record timestamp
date +%s > ~/.wispr_last_use

# Show notification if was frozen
if [[ -f ~/.wispr_frozen ]]; then
    rm -f ~/.wispr_frozen
    osascript -e 'display notification "Wispr Flow active for 5 minutes" with title "Wispr Flow Ready"' 2>/dev/null
fi
