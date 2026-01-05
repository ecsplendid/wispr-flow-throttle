#!/bin/bash
echo "$(date): UNFREEZE TRIGGERED" >> /tmp/wispr-debug.log

defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow" -dict-add pauseInBackground -int 0 limitInBackground -int 0
osascript -e 'tell application "App Tamer" to wake "Wispr Flow"' 2>/dev/null
date +%s > ~/.wispr_last_use

if [[ ! -f ~/.wispr_frozen ]]; then
    exit 0
fi
rm -f ~/.wispr_frozen
osascript -e 'display notification "Wispr Flow unfrozen for 5 minutes" with title "Wispr Flow Active"' 2>/dev/null
