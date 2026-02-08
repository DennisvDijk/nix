# modules/home/features/default.nix
# All feature modules imported together

{ config, pkgs, lib, ... }:

{
  imports = [
    ./user-secrets.nix
    ./shell.nix
    ./cli.nix
    ./git.nix
    ./dev.nix
    ./k8s.nix
    ./ai.nix
    ./terminal.nix
    ./nh.nix
  ];
  
  # Global feature options
  options.my.features = {
    # Individual features are defined in their respective modules
    # This is just to ensure the namespace exists
  };
  
  # Default: enable common features
  config.my.features = {
    shell.enable = lib.mkDefault true;
    cli.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    terminal.enable = lib.mkDefault true;
    nh.enable = lib.mkDefault true;
    # Others disabled by default - enable per-host
  };
}
