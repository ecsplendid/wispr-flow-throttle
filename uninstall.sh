#!/bin/bash
# Wispr Flow Auto-Throttle Uninstaller
# https://github.com/ecsplendid/wispr-flow-throttle

INSTALL_DIR="$HOME/Library/Scripts/WisprThrottle"

echo "========================================"
echo "Wispr Flow Auto-Throttle Uninstaller"
echo "========================================"
echo ""

echo "Unloading LaunchAgent..."
launchctl unload "$HOME/Library/LaunchAgents/com.local.wispr-freeze.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.local.wispr-freeze.plist"
echo "  [OK] LaunchAgent removed"

echo ""
echo "Removing scripts..."
rm -rf "$INSTALL_DIR"
echo "  [OK] Scripts removed"

echo ""
echo "Removing Quick Action..."
rm -rf "$HOME/Library/Services/Unfreeze Wispr Flow.workflow"
echo "  [OK] Quick Action removed"

echo ""
echo "Cleaning up state files..."
rm -f "$HOME/.wispr_last_use" "$HOME/.wispr_frozen"
echo "  [OK] State files removed"

echo ""
echo "Unthrottling Wispr Flow..."
osascript -e 'tell application "App Tamer" to wake "Wispr Flow"' 2>/dev/null || true
echo "  [OK] Wispr Flow unthrottled"

echo ""
echo "========================================"
echo "Uninstallation complete!"
echo "========================================"
echo ""
echo "Note: You may want to manually remove the keyboard shortcut from:"
echo "  System Settings → Keyboard → Keyboard Shortcuts → Services"
