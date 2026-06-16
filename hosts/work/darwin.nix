# hosts/work/darwin.nix
# Work host Darwin configuration — Enexis AI Platform

{ config, pkgs, lib, username, inputs, ... }:

{
  imports = [
    ../../modules/darwin/features
    inputs.mac-app-util.darwinModules.default
    # No sketchybar — that's a personal desktop tool
    # Aerospace is installed via homebrew cask below; config managed by chezmoi
  ];

  # Host identification
  networking.hostName = "work";
  system.stateVersion = 6;

  # Primary user
  system.primaryUser = username;

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Nix configuration — Determinate Nix (same as personal MacBook)
  nix.enable = false;

  # Binary cache for faster builds
  nix.settings.substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # Darwin feature flags
  my.darwin = {
    defaults = {
      enable = true;
      keyboard.enable = true;
      dock.enable = true;
      finder.enable = true;
      trackpad.enable = true;
      menuBar.enable = true;
    };

    homebrew = {
      enable = true;
      nixHomebrew.enable = false;
      autoUpdate = true;
      cleanup = false;
      casks.enable = true;
      brews.enable = true;
      mas.enable = false;
    };
  };

  # Work-specific Homebrew casks
  # NOTE: awscli2 + azure-cli are installed via Nix (k8s.cloud.enable) — not via brew
  # NOTE: Microsoft Office is managed by Enexis Intune — not via brew
  # NOTE: Teams + Zoom intentionally NOT installed (use browser/web client)
  # NOTE: Universal casks (chrome, firefox-nightly, vscode, iterm2, orbstack,
  #       wezterm, raycast, rectangle, stats) live in modules/darwin/features/homebrew.nix
  homebrew.casks = lib.mkAfter [
    # ── Communication ──────────────────────────────────────────────
    "slack"
    "signal"
    "telegram-desktop"

    # ── Browsers ───────────────────────────────────────────────────
    "arc"

    # ── Terminals ──────────────────────────────────────────────────
    "warp"

    # ── AWS / Cloud ────────────────────────────────────────────────
    "aws-vault"

    # ── Kubernetes / Containers ────────────────────────────────────
    "lens"
    "podman-desktop"
    "rancher"

    # ── Database / API tools ───────────────────────────────────────
    "postgres-app"
    "pgadmin4"
    "dbeaver-community"
    "azure-data-studio"
    "bruno"

    # ── AI / LLM tools ─────────────────────────────────────────────
    # Local LLMs (ollama/lm-studio): data stays on-device → residency-safe
    "claude-code"
    "ollama"
    "lm-studio"
    "opencode-desktop"
    "handy"

    # ── Productivity / Notes ───────────────────────────────────────
    "drawio"
    "obsidian"
    "logseq"

    # ── Utilities / Menubar ────────────────────────────────────────
    "bitwarden"
    "thaw"
    "vacuum"

    # ── Media ──────────────────────────────────────────────────────
    "vlc"
    "obs"
    "gimp"
    "anki"

    # ── Fonts ──────────────────────────────────────────────────────
    "font-hack-nerd-font"

    # ── Dev environments ───────────────────────────────────────────
    "flox"

    # ── Window manager — config in hosts/work/dotfiles/home/dot_aerospace.toml
    "nikitabobko/tap/aerospace"
    "cmux"
  ];

  # Work-specific Homebrew brews (CLI tools not in nixpkgs)
  homebrew.brews = lib.mkAfter [
    # AWS SSM Session Manager plugin — not available in nixpkgs
    "session-manager-plugin"

    # Skyhook Radar — network observability / API monitoring
    # Tap: skyhook-io/tap (https://github.com/skyhook-io/homebrew-tap)
    # Version: latest from tap (comment below tracks last pinned version)
    # Last reviewed: 2026-06-09
    # To check for updates: bin/update-radar.sh
    "skyhook-io/tap/radar"
  ];

  # Tap for Skyhook Radar — must be declared explicitly so nix-darwin tracks it
  homebrew.taps = lib.mkAfter [
    {
      name = "skyhook-io/tap";
      clone_target = "https://github.com/skyhook-io/homebrew-tap";
    }
  ];

  # Environment variables
  environment.variables = {
    WORK_ENV = lib.mkForce "1";
    AWS_DEFAULT_REGION = "eu-west-1";    # Data residency: EU only
    AWS_REGION = "eu-west-1";
  };

  # System packages from Nix (minimal — most are in Home Manager)
  environment.systemPackages = with pkgs; [
    home-manager
    git
  ];

  # Auto-check Radar updates on every darwin-rebuild switch
  # Runs in --check (non-interactive) mode; prompts you to run update-radar.sh manually if an update is found
  system.activationScripts.checkRadarUpdate = {
    text = ''
      if command -v brew &>/dev/null && brew list radar &>/dev/null 2>&1; then
        echo "Checking Skyhook Radar for updates..."
        "$HOME/.config/nix/bin/update-radar.sh" --check \
          && echo "  Radar is up to date." \
          || echo "  Run ~/.config/nix/bin/update-radar.sh to review and apply the update."
      fi
    '';
  };

  # Daily background check — pops a macOS notification if an update is available
  launchd.user.agents.radarUpdateCheck = {
    serviceConfig = {
      Label = "io.skyhook.radar-update-check";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''
          if /opt/homebrew/bin/brew list radar &>/dev/null 2>&1; then
            /Users/${config.system.primaryUser}/.config/nix/bin/update-radar.sh --check \
              || /usr/bin/osascript -e 'display notification "Run ~/.config/nix/bin/update-radar.sh to upgrade." with title "Skyhook Radar update available"'
          fi
        ''
      ];
      StartCalendarInterval = [{ Hour = 9; Minute = 0; }];  # Daily at 09:00
      StandardOutPath = "/tmp/radar-update-check.log";
      StandardErrorPath = "/tmp/radar-update-check.log";
    };
  };
}
