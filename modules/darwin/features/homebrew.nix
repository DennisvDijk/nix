# modules/darwin/features/homebrew.nix
# Homebrew integration with nix-homebrew

{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.darwin.homebrew;
in
{
  options.my.darwin.homebrew = {
    enable = mkEnableOption "Homebrew integration" // { default = true; };
    
    nixHomebrew.enable = mkEnableOption "nix-homebrew declarative management" // { default = false; };
    autoUpdate = mkEnableOption "auto-update on activation" // { default = true; };
    cleanup = mkEnableOption "cleanup unused packages" // { default = true; };
    
    # Package categories
    casks.enable = mkEnableOption "GUI applications via casks" // { default = true; };
    brews.enable = mkEnableOption "CLI tools via Homebrew" // { default = false; };  # Prefer Nix!
    mas.enable = mkEnableOption "Mac App Store apps" // { default = false; };
  };

  config = mkIf cfg.enable {
    # Standard Homebrew configuration
    homebrew = {
      enable = true;
      
      onActivation = {
        autoUpdate = cfg.autoUpdate;
        cleanup = if cfg.cleanup then "zap" else "none";
      };

      # Prefer Nix for CLI tools - only use Homebrew when necessary
      # Reasons to use Homebrew over Nix:
      # 1. macOS GUI apps work better (native frameworks, auto-updates)
      # 2. Some tools need macOS-specific features
      # 3. GPU-accelerated tools (Ollama)
      # 4. Tools that auto-update themselves
      
      brews = mkIf cfg.brews.enable [
        # Only put here what CANNOT be in Nix
        # Example: Tools that need specific macOS frameworks
        # Note: opencode and claude-code are in shared/darwin.nix
        "opencode"
      ];

      casks = mkIf cfg.casks.enable [
        # Browsers
        "orion"
        "google-chrome"
        "firefox@nightly"
        
        # Communication
        "signal"
        "whatsapp"
        
        # Media
        "spotify"
        "vlc"
        
        # Development
        "visual-studio-code"
        "iterm2"
        "orbstack"
        "wave"
        
        # AI/ML
        "ollama-app"
        "lm-studio"
        "llamabarn"
        "claude-code"
        
        # Utilities
        "raycast"
        "rectangle"
        "jordanbaird-ice"
        "stats"
        "tailscale-app"
        "parsec"
        
        # Gaming/Fun
        "steam"
        "blender"
        "discord"
        "chatgpt"
        "telegram-desktop"
      ];

      masApps = mkIf cfg.mas.enable {
        # Add Mac App Store apps here
        # "Things 3" = 904280696;
      };

      # Deprecated taps removed (cask-versions and cask-fonts merged into main homebrew/cask)
      taps = [
        # "homebrew/cask-versions"  # Deprecated - merged into homebrew/cask
        # "homebrew/cask-fonts"     # Deprecated - use font- prefixed casks directly
      ];
    };

    # Import nix-homebrew if enabled (requires additional flake inputs)
    # imports = mkIf cfg.nixHomebrew.enable [ 
    #   inputs.nix-homebrew.darwinModules.nix-homebrew 
    # ];
    #
    # nix-homebrew = mkIf cfg.nixHomebrew.enable {
    #   enable = true;
    #   enableRosetta = true;
    #   user = config.my.username;
    #   taps = {
    #     "homebrew/homebrew-core" = inputs.homebrew-core;
    #     "homebrew/homebrew-cask" = inputs.homebrew-cask;
    #   };
    #   mutableTaps = false;
    # };
  };
}
