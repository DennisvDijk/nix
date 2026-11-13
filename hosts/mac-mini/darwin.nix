# hosts/mac-mini/darwin.nix
# Mac Mini — headless home server
# Runs Hermes (docker/media stack), pi-coding-agent, opencode
# Uses personal chezmoi dotfiles (same identity as personal host)

{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/darwin/common.nix
    ../../modules/shared/services/aerospace.nix # occasional display use
    ../../modules/shared/services/headroom.nix
    inputs.mac-app-util.darwinModules.default
    # sketchybar intentionally excluded — this is headless-first
  ];

  # Headless-first: no trackpad. Homebrew formulae are the lean list below,
  # not the shared opencode / llama.cpp / omlx set (brews.enable defaults off).
  my.darwin.defaults.trackpad.enable = false;

  # ── Homebrew — lean; only what the Mini needs ───────────────────
  # Inherits base casks from modules/darwin/features/homebrew.nix:
  #   chrome, firefox@nightly, vscode, iterm2, orbstack, wezterm, raycast, rectangle, stats

  # Extra casks for the Mini
  homebrew.casks = lib.mkAfter [
    # Browsers
    "arc"

    # Container runtime (Hermes, media stack, dev tools)
    # Orbstack comes from base casks already

    # Productivity (occasional GUI use)
    "raycast" # already in base casks; here for clarity

    # Network / Security
    "tailscale-app"
    "bitwarden"

    # Window management (for when a display is connected)
    # aerospace from nikitabobko/tap
    "nikitabobko/tap/aerospace"

    # Fonts
    "font-hack-nerd-font"
  ];

  # Extra taps for the Mini
  homebrew.taps = lib.mkAfter [
    # OpenCode / pi-coding-agent
    {
      name = "anomalyco/tap";
      clone_target = "https://github.com/anomalyco/homebrew-tap";
    }
    {
      name = "typewhisper/tap";
      clone_target = "https://github.com/typewhisper/homebrew-tap";
    }
  ];

  # CLI tools — lean, just pi/opencode essentials
  homebrew.brews = [
    # Pi setup
    "pi-coding-agent"

    # OpenCode setup (fully-qualified tap name so Homebrew finds the formula)
    "anomalyco/tap/opencode"
  ];

  # ── Headroom — context compression proxy for pi agents ──────────
  my.services.headroom = {
    enable = true;
    port = 8787;
    memory = true;
    learn = true;
    codeGraph = true;
  };

  # ── Environment ─────────────────────────────────────────────────
  environment.variables = {
    MINI_ENV = lib.mkForce "1";
  };

  environment.systemPackages = with pkgs; [
    home-manager
    git
    duti
  ];
}
