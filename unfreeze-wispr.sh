#!/bin/bash
# Unfreeze Wispr Flow processes using SIGCONT (no App Tamer needed)

# Find all Wispr Flow processes and send SIGCONT
pids=$(pgrep -f "Wispr Flow")
if [[ -n "$pids" ]]; then
    echo "$pids" | xargs kill -CONT 2>/dev/null
fi

# Record timestamp
date +%s > ~/.wispr_last_use

# Show notification if was frozen
if [[ -f ~/.wispr_frozen ]]; then
    rm -f ~/.wispr_frozen
fi
