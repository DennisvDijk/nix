# Deploy the checkout's dotfiles as writable symlinks.
# `my.flakePath` is the live clone (default ~/.config/nix). Editing a file
# there shows up immediately; Home Manager only has to run again when the
# set of files changes.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.dotfiles;

  translate = name: if lib.hasPrefix "dot_" name then "." + lib.removePrefix "dot_" name else name;

  # relTarget is the path under $HOME. relSource is the path under cfg.root.
  walk =
    dir: targetPrefix: sourcePrefix:
    lib.concatLists (
      lib.mapAttrsToList (
        name: type:
        let
          skip = name == ".chezmoiignore" || lib.hasPrefix ".chezmoi" name;
          targetName = translate name;
          target = if targetPrefix == "" then targetName else "${targetPrefix}/${targetName}";
          sourceRel = if sourcePrefix == "" then name else "${sourcePrefix}/${name}";
        in
        if skip then
          [ ]
        else if type == "directory" then
          walk (dir + "/${name}") target sourceRel
        else
          [
            {
              inherit target sourceRel;
            }
          ]
      ) (builtins.readDir dir)
    );

  sourceDir = ../.. + "/${cfg.root}";
  files = walk sourceDir "" "";

  link = abs: {
    source = config.lib.file.mkOutOfStoreSymlink abs;
    # Replace the regular files chezmoi copied, so the first switch can
    # turn them into these symlinks.
    force = true;
  };

  fileLinks = lib.listToAttrs (
    map (f: {
      name = f.target;
      value =
        let
          value = link "${config.my.flakePath}/${cfg.root}/${f.sourceRel}";
        in
        # Home Manager also writes a generated wezterm.lua. The checkout copy is the one that was on disk.
        if f.target == ".config/wezterm/wezterm.lua" then lib.mkForce value else value;
    }) files
  );

  gsd = link "${config.my.flakePath}/dotfiles/get-shit-done";
in
{
  options.my.flakePath = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.config/nix";
    description = "Absolute path of this repo's checkout. Dotfile symlinks point here.";
  };

  options.my.dotfiles.root = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Repo-relative chezmoi home source, for example hosts/personal/dotfiles/home.";
  };

  config = lib.mkIf (cfg.root != null) {
    home.file = fileLinks // {
      ".config/opencode/get-shit-done" = gsd;
    };
  };
}
