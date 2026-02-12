# Nix Configuration Installer

A one-command installer for setting up Nix, Nix Darwin, and Home Manager on macOS.

## 🚀 Quick Start

```bash
# Download and run the installer
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/nix-config/main/bin/install-nix-config.sh | bash

# Or with specific hostname
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/nix-config/main/bin/install-nix-config.sh | bash -s -- personal
```

## 📋 What This Script Does

### 1. **Prerequisites Check**
- Verifies macOS and Apple Silicon compatibility
- Checks for required permissions

### 2. **Nix Installation**
- Installs Nix package manager if not present
- Configures Nix environment

### 3. **Flakes Enablement**
- Enables experimental Nix flakes feature
- Configures both user and system-level settings

### 4. **Repository Setup**
- Clones the nix-config repository
- Updates if already exists

### 5. **Home Manager Installation**
- Installs Home Manager via nixpkgs
- Applies user-level configuration

### 6. **Darwin System Installation**
- Installs Nix Darwin (macOS system manager)
- Applies system-level configuration

### 7. **SketchyBar Setup**
- Starts SketchyBar status bar
- Adds to login items for auto-start

### 8. **Verification**
- Checks all installed tools
- Verifies configuration is working

## 🎯 Usage

### Basic Usage
```bash
# Use default 'personal' configuration
./bin/install-nix-config.sh

# Use specific hostname
./bin/install-nix-config.sh work
./bin/install-nix-config.sh personal
```

### From Repository
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/nix-config.git ~/.config/nix
cd ~/.config/nix

# Run installer
./bin/install-nix-config.sh [hostname]
```

## 🔧 Available Hosts

- **personal** - Personal Mac configuration
- **work** - Work Mac configuration

## 📦 What's Installed

### System Level (Darwin)
- Aerospace window manager
- SketchyBar status bar
- System packages (alacritty, wezterm, etc.)
- macOS defaults and settings

### User Level (Home Manager)
- Zsh with 100+ git aliases
- Starship prompt
- Development tools (neovim, fzf, bat, etc.)
- Application configurations
- Dotfiles management

## ✅ Post-Installation

After installation completes:

1. **Restart Terminal**
   ```bash
   exec zsh
   ```

2. **Test Git Aliases**
   ```bash
   git-info          # Show repo info
   current_branch    # Show current branch
   g status          # Git status shorthand
   ```

3. **Verify Tools**
   ```bash
   which alacritty
   which sketchybar
   which starship
   ```

## 🔄 Updating Configuration

To update your configuration after initial setup:

```bash
# Navigate to config directory
cd ~/.config/nix

# Pull latest changes
git pull origin main

# Apply updates
home-manager switch --flake .#personal
sudo darwin-rebuild switch --flake .#personal
```

## 🛠️ Troubleshooting

### Permission Issues
```bash
# Fix home directory ownership
sudo chown -R $(whoami):staff ~
```

### Nix Not Found
```bash
# Source Nix environment
. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
```

### Flakes Not Working
```bash
# Manually enable flakes
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

### Home Manager Not Found
```bash
# Install Home Manager manually
nix profile install nixpkgs#home-manager
```

## 📚 Features

- ✅ **One-command installation**
- ✅ **Automatic prerequisite checking**
- ✅ **Idempotent (safe to run multiple times)**
- ✅ **Colored output for clarity**
- ✅ **Error handling and validation**
- ✅ **Multi-host support**
- ✅ **Automatic SketchyBar setup**

## 🔒 Safety

The installer:
- Checks compatibility before proceeding
- Backs up nothing (Nix is declarative and reproducible)
- Can be safely re-run
- Shows exactly what it's doing
- Validates each step

## 📝 Requirements

- macOS (optimized for Apple Silicon)
- Internet connection
- Administrator privileges (for some steps)
- ~2GB free disk space

## 🤝 Contributing

To improve the installer:
1. Test on different macOS versions
2. Report issues with specific hardware
3. Suggest additional safety checks

## 📄 License

Same as the main nix-config repository.

---

**Note**: This installer is designed for macOS systems. For Linux or other systems, modifications would be needed.