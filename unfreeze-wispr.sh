#!/bin/bash
# Unfreeze Wispr Flow via App Tamer and record timestamp

# Set App Tamer to NOT stop Wispr Flow (disable both stop and slow)
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow" -dict-add pauseInBackground -int 0 limitInBackground -int 0
# Use wake command to immediately unfreeze
osascript -e 'tell application "App Tamer" to wake "Wispr Flow"' 2>/dev/null

# Record the current timestamp
date +%s > ~/.wispr_last_use

# Show notification (only if it was actually frozen)
if [[ ! -f ~/.wispr_frozen ]]; then
    exit 0
fi
rm -f ~/.wispr_frozen
osascript -e 'display notification "Wispr Flow unfrozen for 5 minutes" with title "Wispr Flow Active"' 2>/dev/null
