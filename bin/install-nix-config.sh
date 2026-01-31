#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/dennisvandijk/nix-config.git"
NIX_CONFIG_DIR="$HOME/.config/nix"
HOSTNAME="${1:-personal}"  # Default to 'personal' if no argument provided

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Nix Configuration Installer for macOS               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only!"
        exit 1
    fi
    print_success "Running on macOS"
}

# Check architecture
check_architecture() {
    ARCH=$(uname -m)
    if [[ "$ARCH" != "arm64" ]]; then
        print_warning "This configuration is optimized for Apple Silicon (arm64)"
        print_warning "Current architecture: $ARCH"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Apple Silicon (arm64) detected"
    fi
}

# Install Nix if not present
install_nix() {
    if command -v nix &> /dev/null; then
        print_success "Nix is already installed"
        nix --version
    else
        print_status "Installing Nix..."
        curl -L https://nixos.org/nix/install | sh
        
        # Source nix environment
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        
        print_success "Nix installed successfully"
    fi
}

# Enable flakes
enable_flakes() {
    print_status "Enabling Nix flakes..."
    
    # Create Nix config directory
    mkdir -p "$HOME/.config/nix"
    
    # Check if already enabled
    if grep -q "experimental-features.*flakes" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
        print_success "Flakes already enabled"
    else
        echo "experimental-features = nix-command flakes" > "$HOME/.config/nix/nix.conf"
        print_success "Flakes enabled"
    fi
    
    # Also ensure system-level config
    if [ -f /etc/nix/nix.conf ]; then
        if ! grep -q "experimental-features.*flakes" /etc/nix/nix.conf 2>/dev/null; then
            echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf > /dev/null
            print_success "System-level flakes configuration updated"
        fi
    fi
}

# Clone or update repository
setup_repository() {
    print_status "Setting up Nix configuration repository..."
    
    if [ -d "$NIX_CONFIG_DIR/.git" ]; then
        print_status "Repository exists, updating..."
        cd "$NIX_CONFIG_DIR"
        git pull origin main
    else
        print_status "Cloning repository..."
        rm -rf "$NIX_CONFIG_DIR"
        git clone "$REPO_URL" "$NIX_CONFIG_DIR"
        print_success "Repository cloned"
    fi
    
    cd "$NIX_CONFIG_DIR"
}

# Fix ownership issues
fix_ownership() {
    print_status "Checking home directory ownership..."
    
    CURRENT_USER=$(whoami)
    HOME_OWNER=$(stat -f "%Su" "$HOME")
    
    if [[ "$HOME_OWNER" != "$CURRENT_USER" ]]; then
        print_warning "Home directory ownership mismatch detected"
        print_status "Fixing ownership..."
        sudo chown -R "$CURRENT_USER:staff" "$HOME"
        print_success "Ownership fixed"
    else
        print_success "Home directory ownership correct"
    fi
}

# Install Home Manager
install_home_manager() {
    print_status "Installing Home Manager..."
    
    if command -v home-manager &> /dev/null; then
        print_success "Home Manager already installed"
        home-manager --version
    else
        print_status "Installing Home Manager via nixpkgs..."
        nix profile install nixpkgs#home-manager
        print_success "Home Manager installed"
    fi
}

# Apply Home Manager configuration
apply_home_manager() {
    print_status "Applying Home Manager configuration for host: $HOSTNAME..."
    
    cd "$NIX_CONFIG_DIR"
    
    # Check if flake is valid
    if ! nix flake check --show-trace 2>&1 | grep -q "error:"; then
        print_success "Flake configuration is valid"
    else
        print_error "Flake configuration has errors"
        nix flake check --show-trace
        exit 1
    fi
    
    # Apply configuration
    home-manager switch --flake ".#$HOSTNAME"
    
    print_success "Home Manager configuration applied"
}

# Apply Darwin configuration
apply_darwin() {
    print_status "Applying Darwin configuration for host: $HOSTNAME..."
    
    cd "$NIX_CONFIG_DIR"
    
    # Check if nix-darwin is already installed
    if command -v darwin-rebuild &> /dev/null; then
        print_status "Updating Darwin configuration..."
        sudo darwin-rebuild switch --flake ".#$HOSTNAME"
    else
        print_status "Installing Nix Darwin..."
        nix run nix-darwin -- switch --flake ".#$HOSTNAME"
    fi
    
    print_success "Darwin configuration applied"
}

# Setup SketchyBar
setup_sketchybar() {
    print_status "Setting up SketchyBar..."
    
    # Kill existing SketchyBar instances
    pkill -x SketchyBar 2>/dev/null || true
    
    # Start SketchyBar
    if command -v sketchybar &> /dev/null; then
        sketchybar > /tmp/sketchybar.log 2>&1 &
        print_success "SketchyBar started"
        
        # Add to login items
        print_status "Adding SketchyBar to login items..."
        osascript -e 'tell application "System Events" to make login item at end with properties {path:"/run/current-system/sw/bin/sketchybar", hidden:false}' 2>/dev/null || true
        print_success "SketchyBar added to login items"
    else
        print_warning "SketchyBar not found in PATH"
    fi
}

# Post-installation verification
verify_installation() {
    print_status "Verifying installation..."
    
    echo ""
    echo "Checking installed tools:"
    echo "========================"
    
    # Check Nix
    if command -v nix &> /dev/null; then
        echo -e "${GREEN}✓${NC} Nix: $(nix --version)"
    else
        echo -e "${RED}✗${NC} Nix not found"
    fi
    
    # Check Home Manager
    if command -v home-manager &> /dev/null; then
        echo -e "${GREEN}✓${NC} Home Manager: $(home-manager --version)"
    else
        echo -e "${RED}✗${NC} Home Manager not found"
    fi
    
    # Check Darwin
    if command -v darwin-rebuild &> /dev/null; then
        echo -e "${GREEN}✓${NC} Darwin: $(darwin-rebuild --version)"
    else
        echo -e "${RED}✗${NC} Darwin not found"
    fi
    
    # Check key packages
    for pkg in alacritty sketchybar starship; do
        if command -v $pkg &> /dev/null; then
            echo -e "${GREEN}✓${NC} $pkg: $(which $pkg)"
        else
            echo -e "${RED}✗${NC} $pkg not found"
        fi
    done
    
    echo ""
    echo "Checking git aliases:"
    echo "===================="
    if alias g &> /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Git aliases loaded"
    else
        echo -e "${YELLOW}!${NC} Git aliases may need shell reload"
    fi
}

# Print usage
usage() {
    echo "Usage: $0 [hostname]"
    echo ""
    echo "Arguments:"
    echo "  hostname    Host configuration to use (default: personal)"
    echo "              Available: personal, work"
    echo ""
    echo "Examples:"
    echo "  $0              # Use 'personal' configuration"
    echo "  $0 work         # Use 'work' configuration"
    echo "  $0 personal     # Use 'personal' configuration"
}

# Main installation flow
main() {
    # Show usage if --help or -h
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        usage
        exit 0
    fi
    
    echo -e "${BLUE}Starting Nix configuration installation...${NC}"
    echo -e "${BLUE}Hostname: $HOSTNAME${NC}"
    echo ""
    
    # Pre-flight checks
    check_macos
    check_architecture
    
    # Installation steps
    install_nix
    enable_flakes
    fix_ownership
    setup_repository
    install_home_manager
    
    # Apply configurations
    apply_home_manager
    apply_darwin
    
    # Post-setup
    setup_sketchybar
    
    # Verification
    verify_installation
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Installation Complete!                              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: exec zsh"
    echo "2. Test git aliases: git-info, current_branch, g status"
    echo "3. SketchyBar should start automatically on next login"
    echo ""
    echo "To update configuration in the future:"
    echo "  cd ~/.config/nix && git pull"
    echo "  home-manager switch --flake .#$HOSTNAME"
    echo "  sudo darwin-rebuild switch --flake .#$HOSTNAME"
}

# Run main function
main "$@"