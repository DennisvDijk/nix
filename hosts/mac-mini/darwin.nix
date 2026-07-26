# hosts/mac-mini/darwin.nix
# Mac Mini — headless home server
# Runs Hermes (docker/media stack), pi-coding-agent, opencode
# Uses personal chezmoi dotfiles (same identity as personal host)

{ config, pkgs, lib, username, inputs, ... }:

{
  imports = [
    ../../modules/darwin/features                # defaults + homebrew
    ../../modules/shared/services/aerospace.nix  # for occasional display use
    ../../modules/shared/services/headroom.nix   # pi setup: context compression proxy
    inputs.mac-app-util.darwinModules.default
    # NOTE: sketchybar intentionally excluded — this is headless-first
  ];

  # Host identification
  networking.hostName = "mac-mini";
  system.stateVersion = 6;

  # Primary user — same identity as personal MacBook
  system.primaryUser = "dennisvandijk";

  users.users.dennisvandijk = {
    home = "/Users/dennisvandijk";
    shell = pkgs.zsh;
  };

  # Nix — Determinate Nix (same as MacBook, confirmed working)
  nix.enable = false;

  # Binary cache for faster builds
  nix.settings.substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
  nix.settings.trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];

  # Darwin feature flags
  my.darwin = {
    defaults = {
      enable = true;
      keyboard.enable = true;
      dock.enable = true;       # for occasional display use
      finder.enable = true;
      trackpad.enable = false;  # headless-first; no trackpad on Mac Mini
      menuBar.enable = true;
    };

    homebrew = {
      enable = true;
      nixHomebrew.enable = false;
      autoUpdate = true;
      cleanup = false;
      casks.enable = true;      # inherits base casks from homebrew.nix (vscode, orbstack, wezterm, raycast, etc.)
      brews.enable = false;     # define our own lean brew list below
      mas.enable = false;
    };
  };

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
    "raycast"          # already in base casks; here for clarity

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

    # OpenCode setup
    "opencode"

    # Utilities
    "session-manager-plugin"
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

  # System packages from Nix (minimal — most are in Home Manager)
  environment.systemPackages = with pkgs; [
    home-manager
    git
    duti
  ];
}
