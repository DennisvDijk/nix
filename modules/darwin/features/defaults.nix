# modules/darwin/features/defaults.nix
# macOS system defaults via nix-darwin

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.darwin.defaults;
in
{
  options.my.darwin.defaults = {
    enable = mkEnableOption "macOS system defaults" // { default = true; };
    
    keyboard.enable = mkEnableOption "keyboard settings" // { default = true; };
    dock.enable = mkEnableOption "Dock settings" // { default = true; };
    finder.enable = mkEnableOption "Finder settings" // { default = true; };
    trackpad.enable = mkEnableOption "Trackpad settings" // { default = true; };
    menuBar.enable = mkEnableOption "Menu bar settings" // { default = true; };
  };

  config = mkIf cfg.enable {
    # System defaults
    system.defaults = {
      # Keyboard & Global settings
      NSGlobalDomain = lib.mkMerge [
        (mkIf cfg.keyboard.enable {
          ApplePressAndHoldEnabled = false;
          KeyRepeat = 2;
          InitialKeyRepeat = 15;
          AppleShowScrollBars = "WhenScrolling";
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
        })
        (mkIf cfg.menuBar.enable {
          _HIHideMenuBar = false;
        })
      ];

      # Dock
      dock = mkIf cfg.dock.enable {
        autohide = true;
        show-recents = false;
        tilesize = 48;
        largesize = 64;
        magnification = true;
        orientation = "bottom";
        minimize-to-application = true;
        mru-spaces = false;
        persistent-apps = [
          "/Applications/Orion.app"
          "/Applications/WezTerm.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/LM Studio.app"
        ];
      };

      # Finder
      finder = mkIf cfg.finder.enable {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXPreferredViewStyle = "Nlsv";
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        _FXShowPosixPathInTitle = true;
      };

      # Trackpad
      trackpad = mkIf cfg.trackpad.enable {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
      
      # Screensaver
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      # Login window
      loginwindow = {
        GuestEnabled = false;
      };
    };
  };
}
