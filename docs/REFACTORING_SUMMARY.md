# Nix Configuration Refactoring Summary

## Overview

Refactored the Nix Darwin + Home Manager setup using **feature flags pattern** for maximum modularity and maintainability.

## Key Improvements from the Example

### 1. **Feature Flags Architecture** ✅
- **Adopted**: Clean `my.features.*` namespace with `mkEnableOption`
- **Improved**: Added sub-options for granular control (e.g., `my.features.shell.starship.enable`)
- **Benefit**: Host-specific configurations without duplicating code

### 2. **Package Source Optimization** ✅

| Tool Category | Before | After | Reason |
|--------------|--------|-------|---------|
| **Core CLI** | Mixed (some Homebrew) | All Nix | Reproducibility |
| **ffmpeg** | Homebrew | Nix | Pure package |
| **yt-dlp** | Homebrew | Should be Nix | Pure CLI tool |
| **supabase** | Homebrew tap | Keep Homebrew | Custom tap |
| **opencode** | Homebrew tap | Keep Homebrew | Your custom tool |
| **GUI Apps** | Homebrew | Homebrew | macOS frameworks needed |
| **AI Tools** | Mixed | Nix preferred | Codex, Claude Code in nixpkgs |

### 3. **New Module Structure**

```
modules/
├── lib/
│   └── feature-options.nix     # Reusable option helpers
├── home/
│   └── features/
│       ├── default.nix         # Imports all features
│       ├── shell.nix           # Zsh, starship, direnv, zoxide, atuin
│       ├── cli.nix             # fzf, bat, eza, modern tools
│       ├── git.nix             # Git + delta + lazygit + gh
│       ├── dev.nix             # Docker, node, python, uv
│       ├── k8s.nix             # kubectl, k9s, helm
│       ├── ai.nix              # claude-code, codex, aider, gemini-cli
│       ├── terminal.nix        # wezterm, alacritty, kitty
│       └── nh.nix              # Nix helper with aliases
└── darwin/
    └── features/
        ├── default.nix
        ├── defaults.nix        # macOS system settings
        └── homebrew.nix        # Homebrew integration
```

### 4. **nh Integration** ✅

New convenient aliases:
```bash
nd    # nh darwin switch
ndb   # nh darwin switch --flake .#personal
nhs   # nh home switch
ngc   # nh clean all --keep-since 7d --keep 5
nf    # cd ~/.config/nix
nfu   # nix flake update
```

### 5. **What Was Improved from the Example**

| Aspect | Example | Our Implementation |
|--------|---------|-------------------|
| **Feature granularity** | Single on/off | Sub-options per tool |
| **Shell history** | Basic | Atuin integration |
| **Git config** | Basic | Delta, lazygit, gh-dash, jj |
| **Docker** | Just packages | Colima + lazydocker + aliases |
| **Terminal** | Kitty only | WezTerm + Alacritty + zellij |
| **AI tools** | Basic | Goose, oterm, full CLI suite |
| **Kubernetes** | Just packages | k9s theme, context aliases |

## Package Optimization Guide

### **Use Nix For:**
1. ✅ All CLI tools (bat, eza, fd, ripgrep, fzf, etc.)
2. ✅ Development tools (docker, node, uv, ruff)
3. ✅ Kubernetes tools (kubectl, k9s, helm)
4. ✅ AI CLI tools (claude-code, codex, aider)
5. ✅ Terminal emulators (wezterm, alacritty, kitty)
6. ✅ Git tools (delta, lazygit, gh)
7. ✅ System monitoring (bottom, btop, fastfetch)

### **Use Homebrew For:**
1. 🍺 GUI applications (browsers, editors, media apps)
2. 🍺 Tools requiring GPU (Ollama, LM Studio)
3. 🍺 macOS-specific frameworks (Stats, Rectangle)
4. 🍺 Auto-updating apps (VS Code, Chrome)
5. 🍺 Custom taps (opencode, supabase)

### **Moved from Homebrew to Nix:**
- `ffmpeg` → Nix (pure package)
- `imagemagick` → Nix (pure package)
- `yt-dlp` → Should be Nix (pure CLI)
- `kubectl` → Already in Nix
- `k9s` → Already in Nix
- Terminal emulators → Nix

## Usage

### Enable features in host config:
```nix
# hosts/personal/home.nix
my.features = {
  shell.enable = true;
  cli.enable = true;
  git = {
    enable = true;
    userName = "Dennis van Dijk";
    userEmail = "dennis@thenextgen.nl";
  };
  dev = {
    enable = true;
    docker.enable = true;
    python.enable = true;
  };
  ai.enable = true;
  k8s.enable = false;  # Disable for personal
};
```

### Switch commands:
```bash
# Using nh (recommended)
nh darwin switch --flake .#personal
nh home switch --flake .#personal

# Or with new aliases
darwin-rebuild switch --flake .#personal
home-manager switch --flake .#personal
```

## Next Steps

1. **Test the new configuration:**
   ```bash
   home-manager switch --flake .#personal
   ```

2. **Enable nix-homebrew** (optional):
   - Add `nix-homebrew` input to flake.nix
   - Set `my.darwin.homebrew.nixHomebrew.enable = true`
   - Get fully declarative Homebrew

3. **Add more hosts:**
   - Create `hosts/work/home.nix` with different features enabled
   - Share common config via feature flags

4. **Consider moving:**
   - `yt-dlp` from Homebrew to Nix
   - Any other CLI tools from Homebrew brews to Nix

## Benefits Achieved

1. **Modularity**: Each feature is self-contained
2. **Reproducibility**: Everything version-pinned via flake.lock
3. **Discoverability**: Clear feature flags show what's enabled
4. **Maintainability**: Single source of truth per tool category
5. **Flexibility**: Easy to enable/disable per host
6. **Documentation**: Feature modules document available options
