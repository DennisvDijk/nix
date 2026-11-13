# hosts/mac-mini/home.nix
# Mac Mini — headless home server home configuration
# Inherits pi setup (opencode, pi-coding-agent) and personal dotfiles.
# No AI/LLM tools, no comms, no media apps.

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ../../modules/home/common.nix ];

  # Same personal identity and dotfiles. No AI stack, no opencode-tools.
  my.features = {
    shell = {
      starship.enable = false;
      atuin.enable = false;
    };

    git = {
      userName = "Dennis van Dijk";
      userEmail = "dennis@thenextgen.nl";
    };

    nh.defaultDarwinHost = "mac-mini";

    dev.enable = true;

    k8s = {
      enable = true;
      helm.enable = false;
      operators.enable = false;
    };
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
