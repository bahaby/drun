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

# 5. Advanced Cross-Shell PATH Configuration
# Detect the current shell layout precisely by checking the parent process configuration
CURRENT_SHELL=$(basename "$SHELL")
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
SHELL_CONFIG_FILE=""

echo "🐚 Detecting environment shell layout... (Found: $CURRENT_SHELL)"

case "$CURRENT_SHELL" in
    bash)
        # Always target .bashrc for interactive desktop shells
        SHELL_CONFIG_FILE="$HOME/.bashrc"
        [ -f "$SHELL_CONFIG_FILE" ] || touch "$SHELL_CONFIG_FILE"
        
        # Ensure .bash_profile sources .bashrc for login shells (common on macOS)
        if [ -f "$HOME/.bash_profile" ]; then
            if ! grep -Fq '.bashrc' "$HOME/.bash_profile" 2>/dev/null; then
                echo -e "\n# Load .bashrc if it exists\nif [ -f ~/.bashrc ]; then . ~/.bashrc; fi" >> "$HOME/.bash_profile"
            fi
        fi
        ;;
    zsh)
        SHELL_CONFIG_FILE="$HOME/.zshrc"
        [ -f "$SHELL_CONFIG_FILE" ] || touch "$SHELL_CONFIG_FILE"
        ;;
    fish)
        SHELL_CONFIG_FILE="$HOME/.config/fish/config.fish"
        PATH_LINE='fish_add_path $HOME/.local/bin'
        mkdir -p "$(dirname "$SHELL_CONFIG_FILE")"
        [ -f "$SHELL_CONFIG_FILE" ] || touch "$SHELL_CONFIG_FILE"
        ;;
    sh|dash)
        SHELL_CONFIG_FILE="$HOME/.profile"
        [ -f "$SHELL_CONFIG_FILE" ] || touch "$SHELL_CONFIG_FILE"
        ;;
    *)
        echo "⚠️  Unable to automatically configure PATH for shell: $CURRENT_SHELL"
        echo "   Please manually add '$TARGET_DIR' to your system environment variables."
        ;;
esac

# Append path configurations safely without duplicates
if [ -n "$SHELL_CONFIG_FILE" ]; then
    # Check for the EXACT line we are trying to add to prevent messiness
    if ! grep -Fq "$PATH_LINE" "$SHELL_CONFIG_FILE" 2>/dev/null; then
        echo "⚙️  Adding bin configuration path to $SHELL_CONFIG_FILE..."
        echo "" >> "$SHELL_CONFIG_FILE"
        echo "$PATH_LINE" >> "$SHELL_CONFIG_FILE"
        
        echo "========================================================"
        echo "✅ drun installation complete!"
        if [ "$CURRENT_SHELL" = "fish" ]; then
            echo "🔄 Please execute: source $SHELL_CONFIG_FILE"
        else
            echo "🔄 Please execute: source $(basename "$SHELL_CONFIG_FILE")"
        fi
        echo "   or restart your active terminal session to finalize execution."
        echo "========================================================"
    else
        echo "========================================================"
        echo "✅ drun installation complete! (PATH setup already configured)"
        echo "========================================================"
    fi
fi