#!/bin/bash
# Freeze Wispr Flow processes using SIGSTOP (no App Tamer needed)

# Find all Wispr Flow processes and send SIGSTOP
pids=$(pgrep -f "Wispr Flow")
if [[ -n "$pids" ]]; then
    echo "$pids" | xargs kill -STOP 2>/dev/null
fi

# Mark as frozen and clear timestamp
touch ~/.wispr_frozen
rm -f ~/.wispr_last_use

