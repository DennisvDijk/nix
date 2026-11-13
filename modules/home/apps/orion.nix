# Not imported by any host. Kept so the Orion defaults are not deleted.
# Import this file from a home.nix to apply them.
#
# Orion Browser defaults. Not imported by any host today.

{ pkgs, lib, ... }:

let
  # Helper function to write settings to Orion's preferences.
  #
  # FIXED: Replaced the unavailable `gnustep-base` package with a direct
  # call to the system's `defaults` command, which is standard on macOS.
  writeSetting =
    key: type: value:
    "${pkgs.coreutils}/bin/echo 'Writing Orion setting: ${key}' && /usr/bin/defaults write com.kagi.Orion ${key} -${type} '${toString value}'";

  # Helper for writing hotkeys, also updated to use the system's `defaults`.
  writeHotkey =
    title: keybind:
    "/usr/bin/defaults write com.kagi.Orion CustomKeyEquivalents -dict-add '${title}' '${keybind}'";

in
{
  # 1. Install helper utilities
  # We only need `duti` here since Orion is already installed in your darwin-configuration.
  home.packages = [ pkgs.duti ];

  # 2. Configure Orion Settings via an activation script
  home.activation.orionSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${
      pkgs.lib.strings.concatStringsSep "\n" [
        # --- GENERAL ---
        (writeSetting "WebKitDeveloperExtrasEnabled" "bool" "true")

        # --- TABS ---
        (writeSetting "ShouldShowTabSwitcher" "bool" "true")
        (writeSetting "ShouldOpenNewTabsWith" "int" "1")
        (writeSetting "ActiveTabStyle" "int" "1")
        (writeSetting "PinTabs" "int" "1")

        # --- APPEARANCE ---
        (writeSetting "ShouldShowToolbarInFullScreen" "bool" "true")
        (writeSetting "Theme" "int" "2")

        # --- HOTKEYS ---
        # Symbols: @=Cmd, ~=Opt, ^=Ctrl, $=Shift
        "${pkgs.coreutils}/bin/echo 'Writing Orion custom hotkeys'"
        (writeHotkey "Copy Tab URL" "@$c")
        (writeHotkey "Close All Tabs" "@~w")

        # --- PRIVACY ---
        (writeSetting "ContentBlockerEnabled" "bool" "true")
        (writeSetting "TrackingProtectionEnabled" "bool" "true")
      ]
    }
  '';

  # 3. Set Orion as the Default Browser
  home.activation.setDefaultBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.kagi.orion public.html all
    $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.kagi.orion public.url all
    $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.kagi.orion http all
    $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.kagi.orion https all
  '';
}
