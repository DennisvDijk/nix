{ config, pkgs, lib, username, ... }:

{
  imports = [ ../../modules/shared/darwin.nix ];

  # Personal-specific casks
  homebrew.casks = lib.mkAfter [
    "steam"
    "vlc"
  ];

  environment.variables.PERSONAL_ENV = lib.mkForce "1";
}
