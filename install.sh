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

echo ""
echo "Installing scripts..."

# Create install directory
mkdir -p "$INSTALL_DIR"

# Copy scripts
cp "$SCRIPT_DIR/unfreeze-wispr.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/check-wispr-freeze.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/unfreeze-wispr.sh"
chmod +x "$INSTALL_DIR/check-wispr-freeze.sh"

echo "  [OK] Scripts installed to $INSTALL_DIR"

echo ""
echo "Installing Quick Action (for keyboard shortcut)..."

# Copy Quick Action workflow
mkdir -p "$HOME/Library/Services"
cp -r "$SCRIPT_DIR/services/Unfreeze Wispr Flow.workflow" "$HOME/Library/Services/"

echo "  [OK] Quick Action installed"

echo ""
echo "Installing LaunchAgent..."

# Create LaunchAgent
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
    <integer>60</integer>
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
echo "========================================"
echo "Installation complete!"
echo "========================================"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Set up keyboard shortcut:"
echo "   - Open System Settings → Keyboard → Keyboard Shortcuts"
echo "   - Click 'Services' in the sidebar"
echo "   - Find 'Unfreeze Wispr Flow' under General"
echo "   - Double-click and press ⌘\` (or your preferred shortcut)"
echo ""
echo "2. Ensure App Tamer has Accessibility permissions:"
echo "   System Settings → Privacy & Security → Accessibility"
echo ""
echo "3. Test: Press your shortcut to unfreeze Wispr Flow"
echo "   After 5 minutes idle, it will auto-throttle"
echo ""
echo "To uninstall, run: ./uninstall.sh"
