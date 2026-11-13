# AeroSpace package. The config is the dotfile ~/.aerospace.toml
# (hosts/<host>/dotfiles/home/dot_aerospace.toml), symlinked by Home Manager.
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.aerospace ];
}
