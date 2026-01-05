# Wispr Flow Auto-Throttle for macOS

Automatically throttle [Wispr Flow](https://wisprflow.ai/) when not in use to save CPU and battery, then instantly wake it with a keyboard shortcut.

## The Problem

Wispr Flow is a powerful AI voice dictation tool, but it's built on Electron and consumes significant system resources even when idle:

- **~800MB RAM** constantly
- **~8-11% CPU** even when not dictating
- Multiple background processes (10+ Electron helpers)
- Constant cloud connections and screen monitoring

This drains battery and heats up your Mac, even if you only dictate occasionally.

## The Solution

This tool automatically:

1. **Throttles** Wispr Flow to near-zero CPU when you're not using it
2. **Wakes** it instantly when you press **⌘⇧W** (Command+Shift+W)
3. **Re-throttles** after 5 minutes of inactivity
4. Shows **notifications** so you know the current state

### CPU & Battery Savings

Tested on **MacBook Pro M4 Max (128GB RAM)**:

| State | CPU Usage | CPU Time (per hour) | Impact |
|-------|-----------|---------------------|--------|
| Normal (idle) | ~11% | ~6.6 min | Significant battery drain |
| **Throttled** | ~0% | ~0 min | Minimal impact |
| **Savings** | **~100%** | **~6.6 min/hr saved** | Extended battery life |

*CPU percentages shown are aggregate across all Wispr Flow processes (10+ Electron helpers). On Apple Silicon, even "small" percentages translate to meaningful power consumption when sustained 24/7.*

## Requirements

- **macOS Sonoma or later** (tested on macOS 15 Sequoia)
- **[Wispr Flow](https://wisprflow.ai/)** installed
- **[App Tamer](https://www.stclairsoft.com/AppTamer/)** ($15, required for process throttling)

## Installation

### Quick Install

```bash
git clone https://github.com/ecsplendid/wispr-flow-throttle.git
cd wispr-flow-throttle
./install.sh
```

### Manual Installation

1. **Copy scripts:**
   ```bash
   mkdir -p ~/Library/Scripts/WisprThrottle
   cp unfreeze-wispr.sh check-wispr-freeze.sh ~/Library/Scripts/WisprThrottle/
   chmod +x ~/Library/Scripts/WisprThrottle/*.sh
   ```

2. **Install LaunchAgent** (for auto-throttle):
   ```bash
   cp launchd/com.local.wispr-freeze.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.local.wispr-freeze.plist
   ```

3. **Install Quick Action** (for keyboard shortcut):
   ```bash
   cp -r "services/Unfreeze Wispr Flow.workflow" ~/Library/Services/
   ```

4. **Set keyboard shortcut:**
   - Open **System Settings → Keyboard → Keyboard Shortcuts**
   - Click **Services** in the sidebar
   - Find **"Unfreeze Wispr Flow"** under General
   - Double-click and press **⌘⇧W** (or your preferred shortcut)

5. **Grant permissions:**
   - App Tamer needs **Accessibility** permissions:
     - System Settings → Privacy & Security → Accessibility
     - Add and enable `App Tamer`

## Configuration

### Timeout Duration

By default, Wispr Flow re-throttles after **5 minutes** of inactivity. To change this, edit the LaunchAgent:

```bash
nano ~/Library/LaunchAgents/com.local.wispr-freeze.plist
```

Change the `WISPR_TIMEOUT` value (in minutes):
```xml
<key>WISPR_TIMEOUT</key>
<string>10</string>  <!-- 10 minutes -->
```

Then reload:
```bash
launchctl unload ~/Library/LaunchAgents/com.local.wispr-freeze.plist
launchctl load ~/Library/LaunchAgents/com.local.wispr-freeze.plist
```

### Different Hotkey

To change the keyboard shortcut:
1. Open **System Settings → Keyboard → Keyboard Shortcuts**
2. Click **Services** → **General**
3. Find **"Unfreeze Wispr Flow"**
4. Double-click and press your new shortcut

## How It Works

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  macOS Services │────▶│  unfreeze.sh     │────▶│  App Tamer      │
│  (⌘⇧W hotkey)   │     │  (wake Wispr)    │     │  (stop no)      │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                 │
                                 │ writes timestamp
                                 ▼
                         ┌──────────────────┐
                         │  ~/.wispr_last   │
                         │  (timestamp file)│
                         └──────────────────┘
                                 ▲
                                 │ checks every 60s
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  launchd        │────▶│  check-freeze.sh │────▶│  App Tamer      │
│  (periodic)     │     │  (re-throttle)   │     │  (stop yes)     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

1. **macOS Services** detects **⌘⇧W** keyboard shortcut
2. Runs `unfreeze-wispr.sh` which wakes Wispr Flow via App Tamer
3. Script records timestamp of last use
4. **LaunchAgent** runs every 60 seconds checking the timestamp
5. After 5 minutes idle, tells App Tamer to throttle again

## Uninstallation

```bash
./uninstall.sh
```

Or manually:

```bash
# Unload LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.local.wispr-freeze.plist
rm ~/Library/LaunchAgents/com.local.wispr-freeze.plist

# Remove scripts
rm -rf ~/Library/Scripts/WisprThrottle

# Remove Quick Action
rm -rf ~/Library/Services/"Unfreeze Wispr Flow.workflow"

# Clean up state files
rm -f ~/.wispr_last_use ~/.wispr_frozen

# Unthrottle Wispr Flow
osascript -e 'tell application "App Tamer" to wake "Wispr Flow"'
```

## Why App Tamer?

We tried using Unix signals (`SIGSTOP`/`SIGCONT`) to freeze Wispr Flow, but **macOS protects Electron apps** from being stopped this way. App Tamer uses private macOS APIs that can actually throttle GUI applications effectively.

## Why Not Karabiner?

Karabiner-Elements has [known issues](https://github.com/pqrs-org/Karabiner-Elements/issues/4265) with shell command execution on M4 Macs. macOS Services provides a more reliable alternative that works across all Mac models.

## Alternatives Considered

If you find Wispr Flow's resource usage unacceptable even with this tool, consider these lighter alternatives:

| App | CPU Idle | RAM | Processing |
|-----|----------|-----|------------|
| **Wispr Flow** | ~8-11% | 800MB | Cloud |
| **HyperWhisper** | Minimal | Light | Local |
| **Superwhisper** | Low | Varies | Local |
| **VoiceInk** | Low | Light | Local |

## Troubleshooting

### Notifications not appearing
Check that NotificationCenter isn't being throttled by App Tamer:
```bash
osascript -e 'tell application "App Tamer" to manage "NotificationCenter" stop no'
```

### Keyboard shortcut not working
1. Check System Settings → Keyboard → Keyboard Shortcuts → Services
2. Ensure "Unfreeze Wispr Flow" is enabled with your shortcut
3. Try removing and re-adding the shortcut

### Wispr Flow not throttling
Ensure App Tamer is running and has Accessibility permissions.

## License

MIT License - see [LICENSE](LICENSE)

## Author

**Tim Scarfe** ([@ecsplendid](https://github.com/ecsplendid))

## Acknowledgments

- [Wispr Flow](https://wisprflow.ai/) for the excellent (if resource-hungry) dictation tool
- [App Tamer](https://www.stclairsoft.com/AppTamer/) for making process throttling possible
