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

# Check for Karabiner-Elements
if ! [ -d "/Applications/Karabiner-Elements.app" ]; then
    echo "  [!] Karabiner-Elements not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install --cask karabiner-elements
    else
        echo "ERROR: Homebrew not found. Please install Karabiner-Elements manually:"
        echo "  brew install --cask karabiner-elements"
        exit 1
    fi
fi
echo "  [OK] Karabiner-Elements found"

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

# Update paths in scripts to use install directory
sed -i '' "s|/Users/timscarfe/git/syscleanup|$INSTALL_DIR|g" "$INSTALL_DIR/unfreeze-wispr.sh" 2>/dev/null || true
sed -i '' "s|/Users/timscarfe/git/syscleanup|$INSTALL_DIR|g" "$INSTALL_DIR/check-wispr-freeze.sh" 2>/dev/null || true

echo "  [OK] Scripts installed to $INSTALL_DIR"

echo ""
echo "Installing Karabiner configuration..."

# Create Karabiner config directory
mkdir -p "$HOME/.config/karabiner/assets/complex_modifications"

# Create Karabiner config with correct path
cat > "$HOME/.config/karabiner/assets/complex_modifications/wispr-freeze.json" << EOF
{
  "title": "Wispr Flow Auto-Throttle",
  "rules": [
    {
      "description": "Unfreeze Wispr Flow on fn press",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "apple_vendor_keyboard_key_code": "function"
          },
          "to": [
            { "apple_vendor_keyboard_key_code": "function" },
            { "shell_command": "$INSTALL_DIR/unfreeze-wispr.sh" }
          ]
        }
      ]
    }
  ]
}
EOF

echo "  [OK] Karabiner config installed"

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
echo "1. Open Karabiner-Elements"
echo "2. Go to Complex Modifications -> Add rule"
echo "3. Enable 'Unfreeze Wispr Flow on fn press'"
echo ""
echo "4. Ensure App Tamer and Karabiner have Accessibility permissions:"
echo "   System Settings -> Privacy & Security -> Accessibility"
echo ""
echo "5. Test by pressing fn - Wispr Flow should wake up"
echo "   After 5 minutes idle, it will auto-throttle"
echo ""
echo "To uninstall, run: ./uninstall.sh"
