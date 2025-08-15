#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO="vklimontovich/kube-forward"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="kube-forward"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        return 0
    else
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main installation function
main() {
    print_color $GREEN "╔══════════════════════════════════════╗"
    print_color $GREEN "║     kube-forward Installer          ║"
    print_color $GREEN "╚══════════════════════════════════════╝"
    echo ""
    
    # Check for kubectl
    if ! command_exists kubectl; then
        print_color $YELLOW "⚠️  Warning: kubectl not found. You'll need kubectl to use kube-forward."
    fi
    
    # Detect OS
    OS="$(uname -s)"
    case "${OS}" in
        Linux*)     OS_TYPE=Linux;;
        Darwin*)    OS_TYPE=Mac;;
        *)          OS_TYPE="UNKNOWN:${OS}"
    esac
    
    print_color $GREEN "📍 Detected OS: ${OS_TYPE}"
    
    # Check if we need sudo
    SUDO=""
    if ! check_root; then
        if command_exists sudo; then
            SUDO="sudo"
            print_color $YELLOW "🔑 Installation requires sudo privileges"
        else
            print_color $RED "❌ Error: This script requires root privileges or sudo"
            exit 1
        fi
    fi
    
    # Create install directory if it doesn't exist
    if [ ! -d "$INSTALL_DIR" ]; then
        print_color $GREEN "📁 Creating install directory: $INSTALL_DIR"
        $SUDO mkdir -p "$INSTALL_DIR"
    fi
    
    # Check for existing installation
    if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
        print_color $YELLOW "⚠️  Existing installation found at $INSTALL_DIR/$BINARY_NAME"
        
        # Get versions
        CURRENT_VERSION=$($INSTALL_DIR/$BINARY_NAME --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "unknown")
        
        print_color $YELLOW "   Current version: ${CURRENT_VERSION}"
        read -p "   Do you want to update/reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_color $RED "❌ Installation cancelled"
            exit 1
        fi
    fi
    
    # Determine download URL
    print_color $GREEN "🔍 Fetching latest release information..."
    
    # Try to get the latest release version
    LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null || echo "")
    
    if [ -z "$LATEST_RELEASE" ]; then
        print_color $YELLOW "⚠️  Could not fetch latest release, downloading from main branch"
        DOWNLOAD_URL="https://raw.githubusercontent.com/${REPO}/main/${BINARY_NAME}"
    else
        print_color $GREEN "📦 Latest release: ${LATEST_RELEASE}"
        DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_RELEASE}/${BINARY_NAME}"
    fi
    
    # Download the binary
    print_color $GREEN "⬇️  Downloading kube-forward..."
    
    # Create temp file
    TEMP_FILE=$(mktemp)
    trap "rm -f $TEMP_FILE" EXIT
    
    # Download with curl or wget
    if command_exists curl; then
        curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_FILE" || {
            # Fallback to raw file from main branch if release download fails
            print_color $YELLOW "⚠️  Release download failed, trying main branch..."
            curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/${BINARY_NAME}" -o "$TEMP_FILE" || {
                print_color $RED "❌ Error: Failed to download kube-forward"
                exit 1
            }
        }
    elif command_exists wget; then
        wget -q "$DOWNLOAD_URL" -O "$TEMP_FILE" || {
            # Fallback to raw file from main branch if release download fails
            print_color $YELLOW "⚠️  Release download failed, trying main branch..."
            wget -q "https://raw.githubusercontent.com/${REPO}/main/${BINARY_NAME}" -O "$TEMP_FILE" || {
                print_color $RED "❌ Error: Failed to download kube-forward"
                exit 1
            }
        }
    else
        print_color $RED "❌ Error: Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    # Verify download
    if [ ! -s "$TEMP_FILE" ]; then
        print_color $RED "❌ Error: Downloaded file is empty"
        exit 1
    fi
    
    # Make executable
    chmod +x "$TEMP_FILE"
    
    # Move to install directory
    print_color $GREEN "📥 Installing to $INSTALL_DIR/$BINARY_NAME..."
    $SUDO mv "$TEMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
    
    # Verify installation
    if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
        print_color $GREEN "✅ Installation successful!"
        
        # Check if install directory is in PATH
        if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
            print_color $YELLOW "⚠️  Note: $INSTALL_DIR is not in your PATH"
            print_color $YELLOW "   Add it to your PATH by adding this line to your shell profile:"
            print_color $YELLOW "   export PATH=\"\$PATH:$INSTALL_DIR\""
        fi
        
        # Show version
        NEW_VERSION=$($INSTALL_DIR/$BINARY_NAME --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "unknown")
        print_color $GREEN ""
        print_color $GREEN "🎉 kube-forward is ready to use!"
        print_color $GREEN "   Version: ${NEW_VERSION}"
        print_color $GREEN "   Location: $INSTALL_DIR/$BINARY_NAME"
        print_color $GREEN ""
        print_color $GREEN "📖 Usage:"
        print_color $GREEN "   kube-forward --help"
        print_color $GREEN ""
        print_color $GREEN "📚 Example:"
        print_color $GREEN "   kube-forward --forward 5432:database.example.com:5432"
    else
        print_color $RED "❌ Error: Installation failed"
        exit 1
    fi
}

# Handle version flag for the installed script
if [ "$1" == "--version" ]; then
    grep "^VERSION=" "$0" | cut -d'=' -f2
    exit 0
fi

# Run main installation
main "$@"