# Personal Mac only. SketchyBar reads these from ~/.config/sketchybar.
# Home Manager replaces the files on each switch, so a rebuild is idempotent.
_: {
  home.file.".config/sketchybar/sketchybarrc" = {
    source = ../config/sketchybar/sketchybarrc;
    executable = true;
  };

  home.file.".config/sketchybar/workspace_update.sh" = {
    source = ../config/sketchybar/workspace_update.sh;
    executable = true;
  };
}
