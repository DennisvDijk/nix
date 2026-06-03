# hosts/work/darwin.nix
# Work host Darwin configuration — Enexis AI Platform

{ config, pkgs, lib, username, inputs, ... }:

{
  imports = [
    ../../modules/darwin/features
    inputs.mac-app-util.darwinModules.default
    # No aerospace/sketchybar — those are personal desktop tools
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
  homebrew.casks = lib.mkAfter [
    # Communication
    "slack"
    "zoom"
    "microsoft-teams"

    # Browser
    "arc"

    # AWS — aws-vault is not in nixpkgs, brew is appropriate here
    "aws-vault"

    # Kubernetes GUI
    "lens"
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
}
