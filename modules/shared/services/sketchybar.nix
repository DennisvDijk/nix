{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sketchybar
  ];

  # Sketchybar configuration files using mkStoreOutOfSymlink
  home.file.".config/sketchybar/sketchybarrc" = lib.homeManager.mkStoreOutOfSymlink {
    source = ../../../config/sketchybar/sketchybarrc;
    executable = true;
  };
  
  home.file.".config/sketchybar/workspace_update.sh" = lib.homeManager.mkStoreOutOfSymlink {
    source = ../../../config/sketchybar/workspace_update.sh;
    executable = true;
  };
}