{ config, pkgs, lib, username, ... }:

{
  imports = [ ../../modules/shared/darwin.nix ];

  # Work-specific casks
  homebrew.casks = lib.mkAfter [
    "slack"
    "zoom"
    "microsoft-teams"
  ];

  environment.variables.WORK_ENV = lib.mkForce "1";
}
