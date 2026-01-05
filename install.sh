#!/bin/bash
# Wispr Flow Auto-Throttle Installer
# https://github.com/ecsplendid/wispr-flow-throttle

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/Library/Scripts/WisprThrottle"

echo "========================================"
echo "Wispr Flow Auto-Throttle Installer"
echo "========================================"
echo ""

# Check for dependencies
echo "Checking dependencies..."

# Check for App Tamer
if ! [ -d "/Applications/App Tamer.app" ]; then
    echo "ERROR: App Tamer is required but not installed."
    echo "Please install App Tamer from: https://www.stclairsoft.com/AppTamer/"
    exit 1
fi
echo "  [OK] App Tamer found"

# Check for Wispr Flow
if ! [ -d "/Applications/Wispr Flow.app" ]; then
    echo "WARNING: Wispr Flow not found in /Applications"
    echo "This tool is designed for Wispr Flow. Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "  [OK] Wispr Flow found"
fi

# Check macOS version (Tahoe = 26.x)
OS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
if [ "$OS_VERSION" -lt 26 ]; then
    echo "WARNING: This tool requires macOS Tahoe (26) or later for Spotlight Quick Keys."
    echo "Your version: $(sw_vers -productVersion)"
    echo "Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "  [OK] macOS Tahoe or later detected"
fi

echo ""
echo "Installing scripts..."

# Create install directory
mkdir -p "$INSTALL_DIR"

# Copy scripts
cp "$SCRIPT_DIR/unfreeze-wispr.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/freeze-wispr.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/check-wispr-freeze.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/unfreeze-wispr.sh"
chmod +x "$INSTALL_DIR/freeze-wispr.sh"
chmod +x "$INSTALL_DIR/check-wispr-freeze.sh"

echo "  [OK] Scripts installed to $INSTALL_DIR"

echo ""
echo "Installing LaunchAgent..."

# Create LaunchAgent with 15-second check interval
cat > "$HOME/Library/LaunchAgents/com.local.wispr-freeze.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.wispr-freeze</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/check-wispr-freeze.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>15</integer>
    <key>EnvironmentVariables</key>
    <dict>
        <key>WISPR_TIMEOUT</key>
        <string>5</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# Load LaunchAgent
launchctl unload "$HOME/Library/LaunchAgents/com.local.wispr-freeze.plist" 2>/dev/null || true
launchctl load "$HOME/Library/LaunchAgents/com.local.wispr-freeze.plist"

echo "  [OK] LaunchAgent installed and loaded"

echo ""
echo "Configuring App Tamer..."

# Set up App Tamer to freeze Wispr Flow by default
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow" -dict-add pauseInBackground -int 1 limitInBackground -int 0
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow.accessibility-mac-app" -dict-add pauseInBackground -int 1 limitInBackground -int 0

echo "  [OK] App Tamer configured to freeze Wispr Flow"

echo ""
echo "========================================"
echo "Installation complete!"
echo "========================================"
echo ""
echo "NEXT STEPS - Create Spotlight Quick Keys:"
echo ""
echo "1. Open the Shortcuts app"
echo ""
echo "2. Create 'Unfreeze Wispr' shortcut:"
echo "   - Click + to create new shortcut"
echo "   - Add action: Run Shell Script"
echo "   - Paste: $INSTALL_DIR/unfreeze-wispr.sh"
echo "   - Name it 'Unfreeze Wispr'"
echo "   - In sidebar, enable 'Show in Spotlight'"
echo "   - Open Spotlight (⌘Space), search 'Unfreeze Wispr'"
echo "   - Right-click → Add Quick Key → type 'uw'"
echo ""
echo "3. Create 'Freeze Wispr' shortcut:"
echo "   - Click + to create new shortcut"
echo "   - Add action: Run Shell Script"
echo "   - Paste: $INSTALL_DIR/freeze-wispr.sh"
echo "   - Name it 'Freeze Wispr'"
echo "   - Enable 'Show in Spotlight'"
echo "   - Add Quick Key: 'fw'"
echo ""
echo "4. Add Wispr Flow to Login Items:"
echo "   - System Settings → General → Login Items"
echo "   - Add Wispr Flow (it will start frozen)"
echo ""
echo "Usage:"
echo "  ⌘Space → uw → Enter  (wake Wispr)"
echo "  ⌘Space → fw → Enter  (freeze Wispr)"
echo "  Auto-freezes after 5 min idle"
echo ""
echo "To uninstall, run: ./uninstall.sh"
