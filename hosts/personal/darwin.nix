# hosts/personal/darwin.nix
# Personal host Darwin configuration using feature flags

{ config, pkgs, lib, username, ... }:

{
  imports = [
    ../../modules/darwin/features  # Import Darwin feature modules
    ../../modules/shared/services/aerospace.nix
    ../../modules/shared/services/sketchybar.nix
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
      cleanup = true;
      casks.enable = true;
      brews.enable = false;  # Prefer Nix for CLI
      mas.enable = false;
    };
  };

  # Personal-specific Homebrew casks
  homebrew.casks = lib.mkAfter [
    "steam"
    "vlc"
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
