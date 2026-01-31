{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sketchybar
  ];
  
  # Note: SketchyBar should be launched manually or via login items
  # launchd integration has been removed due to compatibility issues
  # See: https://github.com/FelixKratz/SketchyBar/issues/553
}