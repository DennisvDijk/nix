{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
  ];
}