#!/bin/bash
# Explicitly freeze Wispr Flow and its helper via App Tamer

# Freeze main app
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow" -dict-add pauseInBackground -int 1 limitInBackground -int 0

# Freeze accessibility helper
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow.accessibility-mac-app" -dict-add pauseInBackground -int 1 limitInBackground -int 0

# Restart App Tamer to apply
osascript -e 'tell application "App Tamer" to quit' 2>/dev/null
sleep 0.5
open -a "App Tamer"

# Mark as frozen and clear timestamp
touch ~/.wispr_frozen
rm -f ~/.wispr_last_use

osascript -e 'display notification "Wispr Flow frozen. Type uw in Spotlight to wake." with title "Wispr Flow Frozen"' 2>/dev/null
