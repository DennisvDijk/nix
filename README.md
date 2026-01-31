# Nix Configuration Repository

This repository contains a comprehensive Nix-based configuration for macOS systems using Nix Darwin and Home Manager. The configuration follows modern Nix best practices and provides a declarative, reproducible system setup.

## 🗂️ Repository Structure

```
.
├── flake.nix                  # Main flake configuration
├── flake.lock                 # Flake dependencies lock file
├── hosts/                     # Host-specific configurations
│   ├── personal/              # Personal machine config
│   │   ├── darwin.nix         # Darwin system config
│   │   └── home.nix           # Home Manager config
│   └── work/                  # Work machine config
│       ├── darwin.nix         # Darwin system config
│       └── home.nix           # Home Manager config
├── modules/                   # Reusable Nix modules
│   ├── shared/                # Shared configuration modules
│   │   ├── darwin.nix         # Shared Darwin configuration
│   │   ├── home-manager.nix   # Shared Home Manager config
│   │   ├── services/          # Service modules
│   │   │   ├── aerospace.nix  # Aerospace window manager
│   │   │   ├── sketchybar.nix # Sketchybar status bar
│   │   │   └── wezterm.nix    # Wezterm terminal
│   │   ├── programs/          # Program modules
│   │   │   ├── chromium.nix   # Chromium browser config
│   │   │   ├── starship.nix   # Starship prompt
│   │   │   └── zsh.nix        # Zsh shell config
│   │   └── ui/                # UI-related modules
│   │       ├── fonts.nix      # Font configuration
│   │       └── terminal.nix   # Terminal config
│   └── home/                  # Home-specific modules
│       ├── apps/              # Application configs
│       │   ├── orion.nix      # Orion browser config
│       │   └── vscode/        # VSCode configuration
│       │       ├── extensions.nix
│       │       └── settings.nix
│       └── darwin/            # Darwin-specific home configs
│           ├── casks.nix      # Homebrew casks list
│           ├── default.nix    # Default config
│           ├── packages.nix   # Package list
│           └── home-manager.nix
├── bin/                       # Utility scripts
│   ├── add-package.sh        # Add packages helper
│   ├── search_package.sh     # Package search tool
│   └── update-homebrew.sh    # Homebrew sync tool
├── config/                    # Configuration files
│   ├── aerospace.toml        # Aerospace config
│   ├── opencode/             # OpenCode configuration
│   │   └── opencode.json     # OpenCode settings
│   └── sketchybar/           # Sketchybar configuration
│       ├── sketchybarrc      # Sketchybar main config
│       └── workspace_update.sh # Workspace update script
├── hosts/                    # Host configurations
│   ├── personal/             # Personal host
│   │   ├── darwin.nix        # Personal Darwin config
│   │   └── home.nix          # Personal Home Manager config
│   └── work/                 # Work host
│       ├── darwin.nix        # Work Darwin config
│       └── home.nix          # Work Home Manager config
└── README.md                 # This file
```

## 🚀 Features

### Core Configuration
- **Nix Flakes** support with flake-utils integration
- **Multi-host** configuration (personal and work setups)
- **Modular architecture** for easy maintenance
- **Darwin System** configuration with Nix Darwin
- **Home Manager** for user environment management

### Window Management
- **Aerospace** tiling window manager
- **Sketchybar** status bar with workspace integration
- Custom workspace indicators and app icons

### Development Environment
- **Zsh** with Oh My Zsh integration
- **Starship** prompt with custom configuration
- **Neovim**, **VSCode**, and other development tools
- **Direnv** and **Nix-direnv** for environment management

### Productivity Tools
- **Raycast**, **Rectangle**, and other macOS utilities
- **Alacritty** and **Wezterm** terminal emulators
- **Brave Browser**, **Orion**, and other browsers
- **Spotify**, **WhatsApp**, **Signal** for communication

### AI & Development
- **OpenCode** configuration with LM Studio integration
- **Ollama**, **LM Studio**, and other AI tools
- **Git**, **GitHub CLI**, and version control tools
- **Docker**, **Podman**, and container tools

## 📋 Usage

### Initial Setup

```bash
# Clone this repository
git clone https://github.com/yourusername/nix-config.git ~/.config/nix
cd ~/.config/nix

# Install Nix Darwin
nix run nix-darwin -- switch --flake .#personal

# Set up Home Manager
home-manager switch --flake .#personal
```

### Updating Configuration

```bash
# Pull latest changes
git pull

# Rebuild Darwin system
sudo darwin-rebuild switch --flake ~/.config/nix#personal

# Update Home Manager
home-manager switch --flake ~/.config/nix#personal

# Full rebuild (both system and home)
nix-full-rebuild
```

### Adding Packages

```bash
# Search for packages
./bin/search_package.sh package-name

# Add package to configuration
./bin/add-package.sh package-name
```

## 🎯 Configuration Philosophy

### Modular Design
The configuration is organized into reusable modules:
- **Services**: System services and daemons
- **Programs**: Application configurations
- **UI**: User interface and appearance settings
- **Apps**: Application-specific configurations

### Host-Specific Customization
- **Personal host**: Development and personal tools
- **Work host**: Work-related applications and settings
- **Shared configuration**: Common settings across all hosts

### Best Practices
- **Declarative configuration**: Everything defined in Nix
- **Reproducible environments**: Same configuration across machines
- **Atomic updates**: Safe rollbacks and updates
- **Minimal Homebrew usage**: Prefer Nix packages when available

## 🔍 Workspace Distinction & Design Choices

### Personal vs Work Workspaces

The configuration distinguishes between two primary workspaces:

#### Personal Workspace (`hosts/personal/`)

**Purpose**: Personal development, creative work, and general computing

**Key Characteristics**:
- Development-focused tooling (ffmpeg, imagemagick)
- Personal productivity applications
- Creative and multimedia tools
- More permissive environment variables

**Configuration Files**:
- `hosts/personal/darwin.nix` - System-level personal config
- `hosts/personal/home.nix` - User-level personal config

**Environment**:
```nix
environment.variables.PERSONAL_ENV = "1";
```

**Typical Use Case**:
- Personal projects and open-source development
- Multimedia editing and content creation
- General computing and entertainment

#### Work Workspace (`hosts/work/`)

**Purpose**: Professional work, corporate development, and business applications

**Key Characteristics**:
- Work-specific applications (Slack, Zoom, Microsoft Teams)
- Corporate tooling and compliance
- Work environment variables and settings
- More restrictive configuration for security

**Configuration Files**:
- `hosts/work/darwin.nix` - System-level work config
- `hosts/work/home.nix` - User-level work config

**Environment**:
```nix
environment.variables.WORK_ENV = "1";
environment.variables.COMPANY_DOMAIN = "work.example.com";
```

**Typical Use Case**:
- Corporate development and proprietary projects
- Business communications and meetings
- Enterprise tooling and workflows

### Shared Configuration Strategy

**Rationale**: Maximize code reuse while allowing host-specific customization

**Implementation**:
```nix
# In hosts/personal/darwin.nix
environment.variables.PERSONAL_ENV = lib.mkForce "1";

# In hosts/work/darwin.nix  
environment.variables.WORK_ENV = lib.mkForce "1";
```

**Benefits**:
- Single source of truth for common configuration
- Easy to maintain and update shared settings
- Clear separation of host-specific requirements
- Reduced duplication and configuration drift

### Design Choices Explained

#### 1. **Modular Architecture**

**Choice**: Split configuration into `services/`, `programs/`, `ui/` modules

**Rationale**:
- Improves maintainability and organization
- Allows for selective imports and overrides
- Makes it easier to find and update specific configurations
- Reduces cognitive load when working with the config

**Example**:
```nix
imports = [
  ./services/sketchybar.nix
  ./programs/starship.nix  
  ./programs/zsh.nix
  ./ui/fonts.nix
];
```

#### 2. **Flake-Based Configuration**

**Choice**: Use Nix flakes with flake-utils

**Rationale**:
- Better dependency management
- Reproducible inputs with lock file
- Support for multiple systems/architectures
- Modern Nix best practice

**Implementation**:
```nix
inputs.flake-utils.url = "github:numtide/flake-utils";

outputs = { self, nixpkgs, nix-darwin, home-manager, flake-utils, ... }@inputs:
  flake-utils.lib.eachDefaultSystem (system: { ... });
```

#### 3. **File Management with `mkStoreOutOfSymlink`**

**Choice**: Use `lib.homeManager.mkStoreOutOfSymlink` for config files

**Rationale**:
- Allows applications to modify their own config files
- Maintains proper file permissions
- Creates symlinks instead of copying files
- Better compatibility with GUI applications

**Example**:
```nix
home.file.".config/sketchybar/sketchybarrc" = lib.homeManager.mkStoreOutOfSymlink {
  source = ../../../config/sketchybar/sketchybarrc;
  executable = true;
};
```

#### 4. **Homebrew Integration**

**Choice**: Keep some GUI apps in Homebrew while migrating others to Nix

**Rationale**:
- macOS GUI apps often work better as Homebrew casks
- Some apps have auto-update mechanisms via Homebrew
- Better integration with macOS services
- Gradual migration path to reduce risk

**Strategy**:
```nix
# Nix packages (preferred)
environment.systemPackages = with pkgs; [
  alacritty  # Migrated from Homebrew
  sketchybar
  wezterm
];

# Homebrew casks (GUI apps)
homebrew.casks = [
  "google-chrome"  # Better as cask
  "spotify"        # Better as cask  
  "rectangle"      # macOS-specific
];
```

#### 5. **Environment Variables Strategy**

**Choice**: Use `lib.mkForce` for environment variables

**Rationale**:
- Makes variable setting explicit and intentional
- Prevents accidental overriding
- Clear documentation of required variables
- Better error handling

**Example**:
```nix
environment.variables.PERSONAL_ENV = lib.mkForce "1";
environment.variables.WORK_ENV = lib.mkForce "1";
```

#### 6. **Shell Integration**

**Choice**: Comprehensive Zsh configuration with helper functions

**Rationale**:
- Provides convenient rebuild functions
- Consistent shell experience across hosts
- Integration with Oh My Zsh
- Custom aliases and utilities

**Example**:
```nix
initContent = ''
  function nix-rebuild() {
    local host=''${NIX_HOST:-personal}
    echo "🔨 Rebuilding darwin system for host: $host"
    sudo darwin-rebuild switch --flake ~/.config/nix#$host
  }
'';
```

#### 7. **Window Management**

**Choice**: Aerospace + Sketchybar integration

**Rationale**:
- Aerospace provides tiling window management
- Sketchybar provides status bar with workspace indicators
- Tight integration between window manager and status bar
- macOS-native feel with modern features

**Implementation**:
```nix
# Aerospace configuration
exec-on-workspace-change = ['/bin/bash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
];

# Sketchybar workspace integration
script = "$SCRIPT_DIR/workspace_update.sh";
```

## 🎯 Workspace Selection & Usage

### Choosing the Right Workspace

**Personal Workspace**: Ideal for:
- Personal development and open-source work
- Creative projects and multimedia
- General computing and entertainment
- Development tooling and experimentation

**Work Workspace**: Ideal for:
- Corporate development and proprietary projects
- Business communications and meetings
- Enterprise tooling and workflows
- Compliance and security requirements

### Switching Between Workspaces

```bash
# Switch to personal workspace
export NIX_HOST=personal
nix-full-rebuild

# Switch to work workspace  
export NIX_HOST=work
nix-full-rebuild
```

### Workspace-Specific Configuration

**Personal-Specific** (`hosts/personal/home.nix`):
```nix
programs.zsh.initContent = lib.mkAfter ''
  export PERSONAL_ENV=1
  export NIX_HOST="personal"
'';

home.packages = with pkgs; [
  ffmpeg
  imagemagick
];
```

**Work-Specific** (`hosts/work/home.nix`):
```nix
programs.zsh.initContent = lib.mkAfter ''
  export WORK_ENV=1
  export NIX_HOST="work"
  export COMPANY_DOMAIN="work.example.com"
'';
```

## 🔧 Advanced Customization

### Adding New Workspaces

To add a new workspace (e.g., "gaming"):

1. **Create workspace directory**:
```bash
mkdir -p hosts/gaming
```

2. **Create configuration files**:
```bash
touch hosts/gaming/{darwin,home}.nix
```

3. **Add to flake.nix**:
```nix
darwinConfigurations = {
  work = mkDarwinConfig "work";
  personal = mkDarwinConfig "personal";
  gaming = mkDarwinConfig "gaming";  # Add this
};
```

4. **Configure workspace**:
```nix
# hosts/gaming/darwin.nix
{ config, pkgs, lib, username, ... }:
{
  imports = [ ../../modules/shared/darwin.nix ];

  homebrew.casks = lib.mkAfter [
    "steam"
    "epic-games-launcher"
  ];

  environment.variables.GAMING_ENV = lib.mkForce "1";
}
```

### Workspace-Specific Packages

Add packages to specific workspaces:

**Personal workspace**:
```nix
# hosts/personal/home.nix
home.packages = with pkgs; [
  ffmpeg
  imagemagick
  # Personal development tools
];
```

**Work workspace**:
```nix
# hosts/work/home.nix
home.packages = with pkgs; [
  # Work-specific tools
  # Corporate applications
];
```

## 📊 Configuration Statistics

- **Total Nix modules**: 18+ reusable modules
- **Host configurations**: 2 (personal, work) + extensible
- **Service integrations**: 3 (aerospace, sketchybar, wezterm)
- **Program configurations**: 3 (chromium, starship, zsh)
- **Utility scripts**: 3 (package management helpers)
- **Configuration files**: 4 (aerospace, opencode, sketchybar scripts)

## 🎓 Best Practices for Extending

1. **Follow the modular pattern**: Create new modules in appropriate directories
2. **Use `mkStoreOutOfSymlink`**: For application configuration files
3. **Document changes**: Add comments explaining non-obvious choices
4. **Test incrementally**: Rebuild and test after each significant change
5. **Prefer Nix packages**: Migrate from Homebrew when possible
6. **Keep shared config minimal**: Move host-specific settings to host configs
7. **Use `lib.mkForce`**: For environment variables and critical settings

## 🔍 Troubleshooting Workspace Issues

### Common Workspace Problems

**Wrong workspace loaded**:
```bash
# Check current workspace
echo $NIX_HOST

# Switch workspace
export NIX_HOST=personal
# or
NIX_HOST=personal home-manager switch --flake ~/.config/nix#personal
```

**Configuration not applying**:
```bash
# Force rebuild
home-manager switch --flake ~/.config/nix#personal --show-trace

# Check for errors
journalctl -u home-manager -f
```

**Environment variables missing**:
```bash
# Check variables
printenv | grep ENV

# Verify shell integration
source ~/.zshrc
```

## 📚 Additional Resources

- **NixOS Manual**: https://nixos.org/manual
- **Home Manager**: https://nix-community.github.io/home-manager
- **Nix Darwin**: https://github.com/LnL7/nix-darwin
- **Nix Pills**: https://nixos.org/guides/nix-pills
- **Nix Flakes**: https://nixos.wiki/wiki/Flakes

## 🤝 Community & Support

While this is a personal configuration, it follows community best practices:
- **NixOS Discourse**: https://discourse.nixos.org
- **NixOS Wiki**: https://nixos.wiki
- **GitHub Issues**: For specific problems with this config
- **IRC/Matrix**: #nixos on Libera.Chat or Matrix

## 📜 Version History

- **2026**: Comprehensive refactoring and modernization
- **2025**: Initial flake-based configuration
- **2024**: Migration from ad-hoc scripts to Nix

## 🙏 Acknowledgments

This configuration builds upon the work of:
- NixOS community and contributors
- Home Manager maintainers
- Nix Darwin developers
- Various open-source projects and tools

Special thanks to the creators of:
- Aerospace window manager
- Sketchybar status bar
- Starship prompt
- All the amazing CLI tools and applications

---

*Configuration Type: Personal/Work Multi-Host Nix Setup*
*Maintenance Level: Actively Maintained*
*Documentation Status: Comprehensive*


## 🔧 Customization

### Adding New Packages
1. Add to `modules/shared/home-manager.nix` for shared packages
2. Add to host-specific `home.nix` for host-only packages
3. Use `environment.systemPackages` for system-wide packages

### Adding New Services
1. Create a new module in `modules/shared/services/`
2. Import it in the appropriate configuration
3. Configure service-specific settings

### Adding Configuration Files
1. Place files in the `config/` directory
2. Reference them using `lib.homeManager.mkStoreOutOfSymlink`
3. Set appropriate permissions if needed

## 📚 Documentation

### File Management
See `FILE_MANAGEMENT_GUIDE.md` for details on:
- Using `mkStoreOutOfSymlink` for application configs
- Managing executable scripts and permissions
- Best practices for configuration files

### Migration Guide
See `MIGRATION_PLAN.md` for:
- Strategies to migrate from Homebrew to Nix
- Package-by-package migration recommendations
- Benefits of Nix package management

## 🔍 Troubleshooting

### Common Issues

**Flake evaluation errors**:
```bash
nix flake check
nix flake update
```

**Home Manager issues**:
```bash
home-manager switch --flake ~/.config/nix#personal --show-trace
```

**Darwin system issues**:
```bash
sudo darwin-rebuild switch --flake ~/.config/nix#personal --show-trace
```

### Debugging Tips
- Check logs in `/var/log/` for system services
- Use `journalctl` for service logs
- Check `~/.config/nixpkgs/home-manager/logs/` for Home Manager issues

## 🤝 Contributing

This configuration is designed for personal use but follows best practices that may be useful to others. Feel free to:
- Fork and adapt for your own needs
- Use as inspiration for your Nix configuration
- Provide feedback or suggestions

## 📜 License

This configuration is provided as-is for personal use. No explicit license is specified.

## 🙏 Acknowledgments

- NixOS community for excellent documentation
- Home Manager contributors for user environment management
- Nix Darwin team for macOS support
- Various open-source projects used in this configuration

---

*Last updated: 2026*
*Maintained by: System Administrator*
