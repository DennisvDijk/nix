# modules/darwin/features/default.nix
# Darwin-specific feature modules

{ config, pkgs, lib, ... }:

{
  imports = [
    ./defaults.nix
    ./homebrew.nix
  ];
  
  # Darwin-specific options namespace
  options.my.darwin = {
    # Individual features defined in their modules
  };
}
