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
echo "Cleaning up state files..."
rm -f "$HOME/.wispr_last_use" "$HOME/.wispr_frozen"
echo "  [OK] State files removed"

echo ""
echo "Resetting App Tamer settings for Wispr Flow..."
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow" -dict-add pauseInBackground -int 0 limitInBackground -int 0
defaults write com.stclairsoft.AppTamer "com.electron.wispr-flow.accessibility-mac-app" -dict-add pauseInBackground -int 0 limitInBackground -int 0
echo "  [OK] App Tamer settings reset"

echo ""
echo "Unthrottling Wispr Flow..."
osascript -e 'tell application "App Tamer" to wake "Wispr Flow"' 2>/dev/null || true
echo "  [OK] Wispr Flow unthrottled"

echo ""
echo "========================================"
echo "Uninstallation complete!"
echo "========================================"
echo ""
echo "Note: Manually remove the Shortcuts you created:"
echo "  - Open Shortcuts app"
echo "  - Delete 'Unfreeze Wispr' and 'Freeze Wispr'"
