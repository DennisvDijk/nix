{ config, pkgs, lib, username, ... }:

{
  imports = [
    ./services/aerospace.nix
    ./services/sketchybar.nix
    ./services/wezterm.nix
  ];

  system.primaryUser = "dennisvandijk";
  nix.enable = true;
  nix.package = pkgs.nixVersions.stable;
  nix.enableFlakes = true;
  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    
    # Homebrew CLI tools (formulae)
    brews = [
      "ffmpeg"
      "supabase/tap/supabase"
      "yt-dlp"
      "anomalyco/tap/opencode"
    ];
    
    # Homebrew taps for special formulae
    taps = [
      "supabase/tap"
      "anomalyco/tap"
    ];
    
    # Shared casks - host-specific ones added in hosts/*/darwin.nix
    casks = [
      "google-chrome"
      "spotify"
      "rectangle"
      "jordanbaird-ice"
      "stats"
      "whatsapp"
      "iterm2"
      "ollama"
      "signal"
      "firefox@nightly"
      "orion"
      "raycast"
      "tailscale-app"
      "visual-studio-code"
      "orbstack"
      "lm-studio"
      "llamabarn"
      "wave"
      "parsec"
      "stats"
      "blender"
      "emdash"
    ];
  };

  users.users.dennisvandijk = {
    home = "/Users/dennisvandijk";
  };

  environment.systemPackages = with pkgs; [
    home-manager
    chatgpt
    discord
    podman
    sketchybar
    wezterm
    alacritty  # Migrated from Homebrew
    k9s
    telegram-desktop
    gnupg
  ];

  # Default: show macOS menu bar
  system.defaults.NSGlobalDomain._HIHideMenuBar = false;

  system.stateVersion = lib.mkForce 6;
}