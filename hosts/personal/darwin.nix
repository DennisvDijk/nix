# hosts/personal/darwin.nix
# Personal host Darwin configuration using feature flags

{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/darwin/common.nix
    ../../modules/shared/services/sketchybar.nix
    ../../modules/shared/services/headroom.nix
  ];

  # llama.cpp and omlx come from the shared Homebrew module.
  # The OpenCode CLI is the Nix package from the agent stack, not this formula.
  my.darwin.homebrew.opencodeCli.enable = false;
  my.darwin.homebrew.brews.enable = true;

  # Personal-specific Homebrew casks
  homebrew.casks = lib.mkAfter [
    # Browsers
    "arc"
    "orion"
    "brave-browser"

    # Communication
    "signal"
    "whatsapp"
    "telegram-desktop"

    # Media
    "spotify"
    "vlc"

    # Development
    "wave"

    # Productivity
    "obsidian"

    # AI/ML
    "handy"
    "ollama-app"
    "lm-studio"
    "llamabarn"
    "claude"
    "typewhisper/tap/typewhisper"

    # Window manager
    "nikitabobko/tap/aerospace"

    # Utilities
    "thaw"
    "tailscale-app"
    "parsec"

    # Gaming/Fun
    "steam"
    "blender"
    "discord"
    "chatgpt"
    "emdash"
    "cmux"
  ];

  homebrew.taps = lib.mkAfter [
    {
      name = "typewhisper/tap";
      clone_target = "https://github.com/typewhisper/homebrew-tap";
    }
  ];

  # Environment variables
  environment.variables = {
    PERSONAL_ENV = lib.mkForce "1";
  };

  # Headroom context compression proxy
  # Requires: uv tool install "headroom-ai[all]"  (binary at ~/.local/bin/headroom)
  # Proxy runs on port 8787, compresses all LLM traffic, provides persistent memory
  my.services.headroom = {
    enable = true;
    port = 8787;
    memory = true;
    learn = true;
    codeGraph = true;
  };

  environment.systemPackages = with pkgs; [
    home-manager
    git
  ];
}
