# hosts/personal/home.nix
# Personal host home configuration using feature flags

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/sketchybar.nix
  ];

  # Only overrides. Everything else is the module default
  # (see modules/home/features and modules/home/features/user-secrets.nix).
  my.features = {
    shell = {
      # chezmoi owns ~/.zshrc and the starship config.
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
    devtools.enable = true;
  };

  # SOPS configuration for secret management (API keys, tokens, passwords)
  sops = {
    age.keyFile = "/Users/dennisvandijk/Library/Application Support/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/example.yaml;

    secrets = { };
  };

  # Personal-specific packages (things not covered by features)
  home.packages = with pkgs; [
    # Shell (chezmoi-managed config — see programs.zsh.enable override above)
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

  # Run chezmoi init/apply on every home-manager switch (chezmoi owns ~/.zshrc)
  home.activation.chezmoiInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dotfiles_source="${config.home.homeDirectory}/.config/nix/hosts/personal/dotfiles"
    chezmoi_dir="${config.home.homeDirectory}/.local/share/chezmoi"
    if [ -d "$dotfiles_source" ]; then
      if [ ! -d "$chezmoi_dir" ]; then
        echo "chezmoi: initialising from local nix repo source..."
        ${pkgs.chezmoi}/bin/chezmoi init --source "$dotfiles_source" --apply --force
      else
        ${pkgs.chezmoi}/bin/chezmoi apply --source "$dotfiles_source" --force
      fi
    fi
  '';
}
