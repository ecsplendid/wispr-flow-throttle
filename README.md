# Wispr Flow Auto-Throttle for macOS

Automatically throttle [Wispr Flow](https://wisprflow.ai/) when not in use to save CPU and battery, then instantly wake it when you press the push-to-talk hotkey.

## The Problem

Wispr Flow is a powerful AI voice dictation tool, but it's built on Electron and consumes significant system resources even when idle:

- **~800MB RAM** constantly
- **~8-11% CPU** even when not dictating
- Multiple background processes (10+ Electron helpers)
- Constant cloud connections and screen monitoring

This drains battery and heats up your Mac, even if you only dictate occasionally.

## The Solution

This tool automatically:

1. **Throttles** Wispr Flow to ~1.5% CPU when you're not using it
2. **Wakes** it instantly when you press the `fn` key (push-to-talk)
3. **Re-throttles** after 5 minutes of inactivity
4. Shows **notifications** so you know the current state

### CPU & Battery Savings

Tested on **MacBook Pro M4 Max (128GB RAM)**:

| State | CPU Usage | CPU Time (per hour) | Impact |
|-------|-----------|---------------------|--------|
| Normal (idle) | ~11% | ~6.6 min | Significant battery drain |
| **Throttled** | ~1.5% | ~0.9 min | Minimal impact |
| **Savings** | **~85%** | **~5.7 min/hr saved** | Extended battery life |

*CPU percentages shown are aggregate across all Wispr Flow processes (10+ Electron helpers). On Apple Silicon, even "small" percentages translate to meaningful power consumption when sustained 24/7.*

## Requirements

- **macOS** (tested on Ventura/Sonoma)
- **[Wispr Flow](https://wisprflow.ai/)** installed
- **[App Tamer](https://www.stclairsoft.com/AppTamer/)** ($15, required for process throttling)
- **[Karabiner-Elements](https://karabiner-elements.pqrs.org/)** (free, for hotkey detection)
- **Homebrew** (for installing Karabiner)

## Installation

### Quick Install

```bash
git clone https://github.com/ecsplendid/wispr-flow-throttle.git
cd wispr-flow-throttle
./install.sh
```

### Manual Installation

1. **Install Karabiner-Elements:**
   ```bash
   brew install --cask karabiner-elements
   ```

2. **Copy scripts:**
   ```bash
   cp unfreeze-wispr.sh check-wispr-freeze.sh ~/Library/Scripts/
   chmod +x ~/Library/Scripts/unfreeze-wispr.sh ~/Library/Scripts/check-wispr-freeze.sh
   ```

3. **Install Karabiner config:**
   ```bash
   mkdir -p ~/.config/karabiner/assets/complex_modifications
   cp karabiner/wispr-freeze.json ~/.config/karabiner/assets/complex_modifications/
   ```

4. **Install LaunchAgent:**
   ```bash
   cp launchd/com.local.wispr-freeze.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.local.wispr-freeze.plist
   ```

5. **Enable Karabiner rule:**
   - Open Karabiner-Elements
   - Go to **Complex Modifications** → **Add rule**
   - Enable **"Unfreeze Wispr Flow on fn press"**

6. **Grant permissions:**
   - Karabiner needs Accessibility permissions
   - App Tamer needs Accessibility permissions

## Configuration

### Timeout Duration

By default, Wispr Flow re-throttles after **5 minutes** of inactivity. To change this, edit the LaunchAgent:

```bash
# Edit the plist
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

If you use a different push-to-talk key, edit the Karabiner config:

```bash
nano ~/.config/karabiner/assets/complex_modifications/wispr-freeze.json
```

Change `"apple_vendor_keyboard_key_code": "function"` to your preferred key.

## How It Works

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Karabiner-     │────▶│  unfreeze.sh     │────▶│  App Tamer      │
│  Elements       │     │  (on fn press)   │     │  (stop no)      │
│  (fn key hook)  │     └──────────────────┘     └─────────────────┘
└─────────────────┘              │
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

1. **Karabiner-Elements** detects `fn` key press
2. Passes through to Wispr Flow AND runs `unfreeze-wispr.sh`
3. Script tells **App Tamer** to stop throttling + records timestamp
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
rm ~/Library/Scripts/unfreeze-wispr.sh ~/Library/Scripts/check-wispr-freeze.sh

# Remove Karabiner config
rm ~/.config/karabiner/assets/complex_modifications/wispr-freeze.json

# Clean up state files
rm -f ~/.wispr_last_use ~/.wispr_frozen

# Unthrottle Wispr Flow
osascript -e 'tell application "App Tamer" to manage "Wispr Flow" stop no'
```

## Why App Tamer?

We tried using Unix signals (`SIGSTOP`/`SIGCONT`) to freeze Wispr Flow, but **macOS protects Electron apps** from being stopped this way. App Tamer uses private macOS APIs that can actually throttle GUI applications effectively.

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

### fn key not triggering unfreeze
1. Open Karabiner-EventViewer
2. Press fn key
3. Check what key code appears
4. Update the Karabiner config if needed

### Wispr Flow not throttling
Ensure App Tamer is running and has Accessibility permissions.

## License

MIT License - see [LICENSE](LICENSE)

## Author

**Tim Scarfe** ([@ecsplendid](https://github.com/ecsplendid))

## Acknowledgments

- [Wispr Flow](https://wisprflow.ai/) for the excellent (if resource-hungry) dictation tool
- [App Tamer](https://www.stclairsoft.com/AppTamer/) for making process throttling possible
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) for powerful keyboard customization
