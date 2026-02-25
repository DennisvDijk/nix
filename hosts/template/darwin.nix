{ config, pkgs, lib, username, hostName, ... }:

{
  imports = [
    ../../modules/shared/darwin.nix
  ];

  # Host identification
  networking.hostName = hostName;
  system.stateVersion = 6;

  # Primary user
  system.primaryUser = username;
  
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Nix configuration
  nix.enable = false;  # Set to true for standard Nix, false for Determinate

  # Darwin feature flags - customize per machine
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

  # Environment variables - customize for this machine
  environment.variables = {
    # TEMPLATE_ENV = lib.mkForce "1";
  };

  # System packages from Nix
  environment.systemPackages = with pkgs; [
    home-manager
    git
  ];
}
