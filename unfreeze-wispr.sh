#!/bin/bash
# Unfreeze Wispr Flow via App Tamer and record timestamp

# Tell App Tamer to stop throttling Wispr Flow
osascript -e 'tell application "App Tamer" to manage "Wispr Flow" stop no slow no' 2>/dev/null

# Record the current timestamp
date +%s > ~/.wispr_last_use

# Show notification (only if it was actually frozen)
if [[ ! -f ~/.wispr_frozen ]]; then
    exit 0
fi
rm -f ~/.wispr_frozen
osascript -e 'display notification "Wispr Flow unfrozen for 5 minutes" with title "Wispr Flow Active"' 2>/dev/null
