# hosts/mac-mini/home.nix
# Mac Mini — headless home server home configuration
# Inherits pi setup (opencode, pi-coding-agent) and personal dotfiles.
# No AI/LLM tools, no comms, no media apps.

{ pkgs, ... }:

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

  # Same tree as personal, including ~/.aerospace.toml. There is no second copy.
  my.dotfiles.root = "hosts/personal/dotfiles/home";

  # ── Packages ────────────────────────────────────────────────────
  # Shell. ~/.zshrc is the checkout symlink, not a generated file.
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

    duti
  ];

  # ── SOPS (optional — uncomment and configure if needed) ─────────
  # sops = {
  #   age.keyFile = "/Users/${username}/Library/Application Support/sops/age/keys.txt";
  #   defaultSopsFile = ../../secrets/mac-mini-secrets.yaml;
  #   secrets = { };
  # };
}
