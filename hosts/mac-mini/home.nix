# hosts/mac-mini/home.nix
# Mac Mini — headless home server home configuration
# Inherits pi setup (opencode, pi-coding-agent) and personal dotfiles.
# No AI/LLM tools, no comms, no media apps.

{ config, pkgs, lib, inputs, username, hostName, ... }:

{
  imports = [
    ../../modules/shared/home-manager.nix    # Base config (core packages)
    ../../modules/home/features              # Feature system
  ];

  # Host identification
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Nix binary cache for faster builds
  nix.settings.substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
  nix.settings.trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];

  # Feature flags — lean for headless server
  my.features = {
    # Shell — managed by chezmoi (same personal dotfiles)
    shell = {
      enable = true;
      starship.enable = false;   # chezmoi manages ~/.zshrc + starship
      direnv.enable  = true;
      zoxide.enable  = true;
      atuin.enable   = false;
    };

    cli.enable = true;

    git = {
      enable = true;
      userName = "Dennis van Dijk";
      userEmail = "dennis@thenextgen.nl";
      delta.enable    = true;
      lazygit.enable  = true;
      jujutsu.enable  = true;
      githubCli.enable  = true;
      gitlabCli.enable  = false;
    };

    terminal = {
      enable = true;
      wezterm.enable  = true;
      alacritty.enable = true;
      kitty.enable    = false;
      iterm2.enable   = true;
    };

    nh = {
      enable = true;
      flakeDir = "${config.home.homeDirectory}/.config/nix";
      defaultDarwinHost = "mac-mini";
    };

    dev = {
      enable = true;
      docker.enable  = true;   # Orbstack + docker CLI
      node.enable    = true;
      python.enable  = true;
      http.enable    = true;
    };

    k8s = {
      enable = true;
      kubectl.enable  = true;
      k9s.enable      = true;
      helm.enable     = false;  # Not needed on home server
      operators.enable = false;
      cloud.enable    = false;
    };

    # No AI/LLM tools — this is a server, not a dev workstation
    ai.enable = false;

    # No self-hosted opencode-tools stack on the Mini
    devtools.enable = false;
  };

  # chezmoi owns ~/.zshrc — disable home-manager's zsh file generation
  programs.zsh.enable = lib.mkForce false;

  # User identity
  my.user = {
    fullName = "Dennis van Dijk";
    firstName = "Dennis";
    lastName = "van Dijk";
    email.personal = "dennis@thenextgen.nl";
    email.git      = "dennis@thenextgen.nl";
    email.work     = "";
    username       = username;
    homeDirectory  = "/Users/${username}";
  };

  # ── Dotfiles ────────────────────────────────────────────────────
  # Reuse personal dotfiles (same chezmoi source as MacBook).
  # pi/opencode config, zshrc, starship.toml, etc. all come from here.
  home.activation.chezmoiInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dotfiles_source="${config.home.homeDirectory}/.config/nix/hosts/personal/dotfiles"
    chezmoi_dir="${config.home.homeDirectory}/.local/share/chezmoi"
    if [ -d "$dotfiles_source" ]; then
      if [ ! -d "$chezmoi_dir" ]; then
        echo "chezmoi: initialising from personal dotfiles..."
        ${pkgs.chezmoi}/bin/chezmoi init --source "$dotfiles_source" --apply --force
      else
        ${pkgs.chezmoi}/bin/chezmoi apply --source "$dotfiles_source" --force
      fi
    fi
  '';

  # ── Packages ────────────────────────────────────────────────────
  # Shell (chezmoi-managed config — see programs.zsh.enable override above)
  home.packages = with pkgs; [
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship
    atuin

    # Shell history layering (zshrc has conditional integrations)
    mcfly
    hstr
    pay-respects

    # Media / utility (lighter than personal)
    ffmpeg
    imagemagick
    mosh

    # Dotfiles management
    chezmoi
    duti
  ];

  # ── SOPS (optional — uncomment and configure if needed) ─────────
  # sops = {
  #   age.keyFile = "/Users/${username}/Library/Application Support/sops/age/keys.txt";
  #   defaultSopsFile = ../../secrets/mac-mini-secrets.yaml;
  #   secrets = { };
  # };
}
