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
echo "Removing Karabiner config..."
rm -f "$HOME/.config/karabiner/assets/complex_modifications/wispr-freeze.json"
echo "  [OK] Karabiner config removed"

echo ""
echo "Cleaning up state files..."
rm -f "$HOME/.wispr_last_use" "$HOME/.wispr_frozen"
echo "  [OK] State files removed"

echo ""
echo "Unthrottling Wispr Flow..."
osascript -e 'tell application "App Tamer" to manage "Wispr Flow" stop no' 2>/dev/null || true
echo "  [OK] Wispr Flow unthrottled"

echo ""
echo "========================================"
echo "Uninstallation complete!"
echo "========================================"
echo ""
echo "Note: Karabiner-Elements and App Tamer were NOT uninstalled."
echo "You may need to manually disable the Karabiner rule if it's still enabled."
