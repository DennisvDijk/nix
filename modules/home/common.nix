# Home Manager baseline for the machines that are actually used.
# The template host does not import this, so it stays a blank slate.
{ lib, ... }:
{
  imports = [
    ../shared/home-manager.nix
    ./features
    ./dotfiles.nix
  ];

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

  # The checkout's dot_zshrc is symlinked to ~/.zshrc. Don't also generate one.
  programs.zsh.enable = lib.mkForce false;
}
