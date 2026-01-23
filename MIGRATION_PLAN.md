# Homebrew to Nix Migration Plan

## Current Homebrew Casks (from darwin.nix):
- spotify
- rectangle  
- alacritty
- iterm2
- ollama
- orion
- raycast
- tailscale
- visual-studio-code
- orbstack
- lm-studio
- llamabarn
- wave
- parsec
- blender

## Migration Strategy:

### 1. Packages to Migrate to Nix (Available in nixpkgs):
- **alacritty** - Terminal emulator (available)
- **tailscale** - VPN service (available)
- **blender** - 3D modeling (available)
- **ollama** - AI tool (likely available)

### 2. Packages to Keep in Homebrew (GUI apps better suited for casks):
- spotify - Music streaming (GUI app, better as cask)
- rectangle - Window management (GUI app, macOS specific)
- iterm2 - Terminal emulator (GUI app, macOS specific)
- orion - Browser (GUI app, macOS specific)
- raycast - Productivity tool (GUI app, macOS specific)
- visual-studio-code - IDE (GUI app, better as cask)
- orbstack - Development tool (GUI app)
- lm-studio - AI tool (GUI app)
- llamabarn - AI tool (GUI app)
- wave - Video tool (GUI app)
- parsec - Remote desktop (GUI app)

### 3. Recommended Migration Steps:

#### Step 1: Add migrated packages to Nix configuration

Edit `/Users/dennisvandijk/.config/nix/modules/shared/darwin.nix`:

```nix
environment.systemPackages = with pkgs; [
  home-manager
  aerospace
  chatgpt
  discord
  podman
  sketchybar
  wezterm
  alacritty  # Add this
  tailscale  # Add this
  blender     # Add this
  ollama      # Add this
];
```

#### Step 2: Remove migrated packages from Homebrew casks

Edit `/Users/dennisvandijk/.config/nix/modules/shared/darwin.nix`:

```nix
# Remove these from homebrew.casks:
# "alacritty"
# "tailscale" 
# "blender"
# "ollama"
```

#### Step 3: Rebuild and test

```bash
sudo darwin-rebuild switch --flake ~/.config/nix#personal
home-manager switch --flake ~/.config/nix#personal
```

#### Step 4: Verify installation

```bash
which alacritty
tailscale status
blender --version
ollama --version
```

## Benefits of This Approach:

1. **Reduced Homebrew dependency**: Fewer casks to manage
2. **Better reproducibility**: Nix packages are more declarative
3. **Atomic upgrades**: Nix allows for safer upgrades
4. **Multi-user support**: Nix packages can be shared across users
5. **Rollback capability**: Easy to rollback if something breaks

## Packages That Should Stay in Homebrew:

The GUI applications are better managed through Homebrew casks because:
- They're macOS-specific .app bundles
- They often have auto-update mechanisms
- They integrate better with macOS services
- They're updated more frequently than Nix packages
- They handle GUI permissions better

## Implementation Recommendation:

Start with migrating `alacritty` first as it's a terminal application and least likely to cause issues. Then gradually migrate others if needed.

Would you like me to implement this migration plan for alacritty now?