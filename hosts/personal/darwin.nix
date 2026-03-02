# hosts/personal/darwin.nix
# Personal host Darwin configuration using feature flags

{ config, pkgs, lib, username, inputs, ... }:

{
  imports = [
    ../../modules/darwin/features  # Import Darwin feature modules
    ../../modules/shared/services/aerospace.nix
    ../../modules/shared/services/sketchybar.nix
    inputs.mac-app-util.darwinModules.default
  ];

  # Host identification
  networking.hostName = "personal";
  system.stateVersion = 6;

  # Primary user
  system.primaryUser = "dennisvandijk";
  
  users.users.dennisvandijk = {
    home = "/Users/dennisvandijk";
    shell = pkgs.zsh;
  };

  # Nix configuration
  # MacBook gebruikt Determinate Nix, Mac Mini niet
  # Op Mac Mini: verander naar nix.enable = true
  nix.enable = false;  # false voor Determinate, true voor standaard Nix

  # Binary cache for faster builds
  nix.settings.substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
  nix.settings.trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];

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
      nixHomebrew.enable = false;  # Can enable later
      autoUpdate = true;
      cleanup = false;
      casks.enable = true;
      brews.enable = true;  # Enable voor opencode en andere custom tools
      mas.enable = false;
    };
  };

  # Personal-specific Homebrew casks
  homebrew.casks = lib.mkAfter [
    "steam"
    "vlc"
    "emdash"
  ];

  # Environment variables
  environment.variables = {
    PERSONAL_ENV = lib.mkForce "1";
  };

  # System packages from Nix (minimal - most are in Home Manager)
  environment.systemPackages = with pkgs; [
    home-manager
    git
  ];
}
