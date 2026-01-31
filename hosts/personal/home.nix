{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/home-manager.nix
  ];

  # Personal-specific environment variable
  programs.zsh.initContent = lib.mkAfter ''
    export PERSONAL_ENV=1
    export NIX_HOST="personal"
  '';

  # Personal-specific packages
  home.packages = with pkgs; [
    ffmpeg
    imagemagick
  ];
}
