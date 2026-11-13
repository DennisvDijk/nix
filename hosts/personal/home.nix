# hosts/personal/home.nix
# Personal host home configuration using feature flags

{ pkgs, ... }:

{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/sketchybar.nix
  ];

  # Only overrides. Everything else is the module default
  # (see modules/home/features and modules/home/features/user-secrets.nix).
  my.features = {
    shell = {
      # ~/.zshrc and starship.toml are symlinks into this checkout.
      starship.enable = false;
      atuin.enable = false;
    };

    git = {
      userName = "Dennis van Dijk";
      userEmail = "dennis@thenextgen.nl";
    };

    dev.enable = true;

    k8s = {
      enable = true;
      helm.enable = false;
      operators.enable = false;
    };

    ai.enable = true;
    ai.agentStack.enable = true;
    devtools.enable = true;
  };

  my.dotfiles.root = "hosts/personal/dotfiles/home";

  # SOPS configuration for secret management (API keys, tokens, passwords)
  sops = {
    age.keyFile = "/Users/dennisvandijk/Library/Application Support/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/example.yaml;

    secrets = { };
  };

  # Personal-specific packages (things not covered by features)
  home.packages = with pkgs; [
    # Shell. ~/.zshrc is the checkout symlink, not a generated file.
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship
    atuin

    # Shell history layering (zshrc has conditional integrations for all three)
    mcfly
    hstr
    pay-respects

    # Media tools (personal-specific)
    ffmpeg
    imagemagick
    moonlight-qt
    mosh
  ];
}
