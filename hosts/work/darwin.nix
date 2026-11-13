# hosts/work/darwin.nix
# Work host Darwin configuration — Enexis AI Platform

{
  config,
  pkgs,
  lib,
  username,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/darwin/common.nix
    inputs.mac-app-util.darwinModules.default
    # No sketchybar — that's a personal desktop tool.
    # Aerospace config is ~/.aerospace.toml, a Home Manager symlink.
  ];

  my.darwin.homebrew.brews.enable = true;

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
    "finicky"

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
    "typewhisper/tap/typewhisper"

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
      name = "typewhisper/tap";
      clone_target = "https://github.com/typewhisper/homebrew-tap";
    }
    {
      name = "skyhook-io/tap";
      clone_target = "https://github.com/skyhook-io/homebrew-tap";
    }
  ];

  # Environment variables
  environment.variables = {
    WORK_ENV = lib.mkForce "1";
    AWS_DEFAULT_REGION = "eu-west-1"; # Data residency: EU only
    AWS_REGION = "eu-west-1";
  };

  # Keep Finicky as the managed HTTPS entry point. Run after Homebrew so a
  # newly installed Finicky app can become the handler in the same switch.
  # postActivation is one of the script names nix-darwin actually runs.
  # Finicky and the Radar check both belong here. checkRadarUpdate was a
  # custom name, so the Radar check never ran.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    if [ -x "${pkgs.duti}/bin/duti" ] && [ -d "/Applications/Finicky.app" ]; then
      echo "Setting Finicky as the default HTTPS handler..."
      sudo -u ${username} -H ${pkgs.duti}/bin/duti -s se.johnste.finicky https all
    else
      echo "Finicky is not installed yet; skipping default HTTPS handler setup."
    fi

    # --check is read-only. Run as the user so Homebrew sees their cellar.
    if sudo -u ${username} -H /opt/homebrew/bin/brew list radar >/dev/null 2>&1; then
      echo "Checking Skyhook Radar for updates..."
      sudo -u ${username} -H "/Users/${username}/.config/nix/bin/update-radar.sh" --check \
        && echo "  Radar is up to date." \
        || echo "  Run ~/.config/nix/bin/update-radar.sh to review and apply the update."
    fi
  '';

  # Daily background check — pops a macOS notification if an update is available
  environment.systemPackages = with pkgs; [
    home-manager
    git
  ];

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
      StartCalendarInterval = [
        {
          Hour = 9;
          Minute = 0;
        }
      ]; # Daily at 09:00
      StandardOutPath = "/tmp/radar-update-check.log";
      StandardErrorPath = "/tmp/radar-update-check.log";
    };
  };
}
