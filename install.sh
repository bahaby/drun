#!/usr/bin/env bash

# Exit immediately on errors, unassigned variables, or broken pipes
set -euo pipefail

echo "========================================================"
echo "🐳 drun Installer"
echo "========================================================"

# 1. Configuration
RAW_DRUN_URL="https://raw.githubusercontent.com/bahaby/drun/main/drun"
TARGET_DIR="$HOME/.local/bin"

# 2. Dependency Checks
echo "🔍 Checking dependencies..."
if ! command -v curl &>/dev/null; then
    echo "❌ Error: 'curl' is required but not installed. Please install it first."
    exit 1
fi

if ! command -v docker &>/dev/null; then
    echo "⚠️  Warning: 'docker' command line tool was not detected on this system."
    echo "   You can still install drun, but make sure Docker is installed to use it!"
fi

# 3. Setup Target Directory
if [ ! -d "$TARGET_DIR" ]; then
    echo "📁 Creating local binaries directory at $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
fi

# 4. Download and Deploy drun
echo "📥 Downloading drun..."
if ! curl -fsSL "$RAW_DRUN_URL" -o "$TARGET_DIR/drun"; then
    echo "❌ Error: Failed to download drun from GitHub."
    echo "   Please double-check that the repository is public and the user configuration is correct."
    exit 1
fi

chmod +x "$TARGET_DIR/drun"

# ==============================================================================
# 5. Advanced Cross-Shell PATH Configuration
# ==============================================================================
CURRENT_SHELL=$(basename "$SHELL")
SHELL_CONFIG_FILE=""

# Check standard profile targets based on the user's active shell
case "$CURRENT_SHELL" in
    bash)    SHELL_CONFIG_FILE="$HOME/.bashrc" ;;
    zsh)     SHELL_CONFIG_FILE="$HOME/.zshrc" ;;
    fish)    SHELL_CONFIG_FILE="$HOME/.config/fish/config.fish" ;;
    sh|dash) SHELL_CONFIG_FILE="$HOME/.profile" ;;
esac

echo "🐚 Detecting environment shell layout... (Found: $CURRENT_SHELL)"

if [ -n "$SHELL_CONFIG_FILE" ]; then
    # Ensure the target configuration directory and file exist
    [ -f "$SHELL_CONFIG_FILE" ] || mkdir -p "$(dirname "$SHELL_CONFIG_FILE")" && touch "$SHELL_CONFIG_FILE"

    # Define the precise injection line for adding the path cleanly
    if [ "$CURRENT_SHELL" = "fish" ]; then
        PATH_LINE='fish_add_path $HOME/.local/bin'
        # Regular expression for fish files checking for .local/bin
        GREP_REGEX="fish_add_path.*\.local/bin"
    else
        PATH_LINE='if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then PATH="$HOME/.local/bin:$PATH"; fi; export PATH'
        # SMART REGEX: Matches any active line containing .local/bin, catching variations
        # like: export PATH="$HOME/.local/bin:$PATH", PATH=~/.local/bin:$PATH, etc.
        # It explicitly ignores lines that are commented out with '#'
        GREP_REGEX="^[[:space:]]*[^#]*\.local/bin"
    fi

    # Check the file contents using the smart regex match
    if grep -Eiq "$GREP_REGEX" "$SHELL_CONFIG_FILE" 2>/dev/null; then
        echo "========================================================"
        echo "✅ drun installation complete! (PATH configurations already exist in $SHELL_CONFIG_FILE)"
        echo "========================================================"
    else
        echo "⚙️  Adding bin configuration path to $SHELL_CONFIG_FILE..."
        echo "" >> "$SHELL_CONFIG_FILE"
        echo "$PATH_LINE" >> "$SHELL_CONFIG_FILE"
        
        # If running Bash and .bash_profile exists, safely ensure it triggers .bashrc
        if [ "$CURRENT_SHELL" = "bash" ] && [ -f "$HOME/.bash_profile" ]; then
            if ! grep -Fq '.bashrc' "$HOME/.bash_profile" 2>/dev/null; then
                echo -e "\n# Load .bashrc if it exists\nif [ -f ~/.bashrc ]; then . ~/.bashrc; fi" >> "$HOME/.bash_profile"
            fi
        fi

        echo "========================================================"
        echo "✅ drun installation complete!"
        if [ "$CURRENT_SHELL" = "fish" ]; then
            echo "🔄 Please execute: source $SHELL_CONFIG_FILE"
        else
            echo "🔄 Please execute: source $(basename "$SHELL_CONFIG_FILE")"
        fi
        echo "   or restart your active terminal session to finalize execution."
        echo "========================================================"
    fi
else
    echo "⚠️  Unable to automatically configure path targets for shell: $CURRENT_SHELL"
    echo "   Please manually add '\$HOME/.local/bin' to your system environment variables."
fi