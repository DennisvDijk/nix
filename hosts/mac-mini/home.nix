# Headless Mac mini. Pi's config and the shell rc are symlinks into this checkout.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  link = rel: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.my.flakePath}/${rel}";
    force = true;
  };
in
{
  imports = [ ../../modules/home/dotfiles.nix ];

  home.username = "dennisvandijk";
  home.homeDirectory = "/Users/dennisvandijk";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  nix.package = pkgs.nix;
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # ~/.zshrc is the checkout symlink below.
  programs.zsh.enable = lib.mkForce false;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Dennis van Dijk";
      user.email = "dennis@thenextgen.nl";
      init.defaultBranch = "main";
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  home.packages = with pkgs; [
    zsh
    tmux
    git
    ripgrep
    fd
    jq
  ];

  home.file = {
    ".zshrc" = link "hosts/mac-mini/dotfiles/zshrc";
    ".pi" = link "hosts/mac-mini/dotfiles/pi";
  };
}
