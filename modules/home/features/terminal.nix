# modules/home/features/terminal.nix
# Terminal emulators configuration

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.features.terminal;
in
{
  options.my.features.terminal = {
    enable = mkEnableOption "terminal emulators";
    
    wezterm.enable = mkEnableOption "WezTerm" // { default = true; };
    alacritty.enable = mkEnableOption "Alacritty" // { default = true; };
    kitty.enable = mkEnableOption "Kitty" // { default = false; };
    iterm2.enable = mkEnableOption "iTerm2 (via Homebrew)" // { default = true; };
  };

  config = mkIf cfg.enable {
    # WezTerm - installed via Nix, configured via home.file
    programs.wezterm = mkIf cfg.wezterm.enable {
      enable = true;
      # Config is managed via home.file below for full Lua control
    };

    home.file.".config/wezterm/wezterm.lua".text = lib.mkIf cfg.wezterm.enable ''
      local wezterm = require 'wezterm'

      return {
        -- Catppuccin Mocha theme
        color_scheme = 'Catppuccin Mocha',

        -- Font configuration
        font = wezterm.font('JetBrainsMono Nerd Font'),
        font_size = 13.0,

        -- Window settings
        window_decorations = 'RESIZE',
        window_background_opacity = 0.95,

        -- Tab bar
        enable_tab_bar = true,
        use_fancy_tab_bar = false,
        hide_tab_bar_if_only_one_tab = true,

        -- Scrollback
        scrollback_lines = 10000,

        -- Key bindings
        keys = {
          { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
          { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentTab { confirm = true } },
        },

        -- Default shell
        default_prog = { '${pkgs.zsh}/bin/zsh', '-l' },
      }
    '';


    # Alacritty - installed via Nix
    programs.alacritty = mkIf cfg.alacritty.enable {
      enable = true;
      settings = {
        window = {
          opacity = 0.95;
          padding = {
            x = 5;
            y = 5;
          };
        };
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          size = 13.0;
        };
        colors = {
          primary = {
            background = "#1e1e2e";
            foreground = "#cdd6f4";
          };
          cursor = {
            text = "#1e1e2e";
            cursor = "#f5e0dc";
          };
          normal = {
            black = "#45475a";
            red = "#f38ba8";
            green = "#a6e3a1";
            yellow = "#f9e2af";
            blue = "#89b4fa";
            magenta = "#f5c2e7";
            cyan = "#94e2d5";
            white = "#bac2de";
          };
          bright = {
            black = "#585b70";
            red = "#f38ba8";
            green = "#a6e3a1";
            yellow = "#f9e2af";
            blue = "#89b4fa";
            magenta = "#f5c2e7";
            cyan = "#94e2d5";
            white = "#a6adc8";
          };
        };
        scrolling = {
          history = 10000;
        };
        selection = {
          save_to_clipboard = true;
        };
        shell = {
          program = "${pkgs.zsh}/bin/zsh";
          args = [ "-l" ];
        };
      };
    };

    # Kitty - installed via Nix if enabled
    programs.kitty = mkIf cfg.kitty.enable {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 13;
      };
      theme = "Catppuccin-Mocha";
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        window_padding_width = 5;
        background_opacity = "0.95";
        scrollback_lines = 10000;
        shell = "${pkgs.zsh}/bin/zsh -l";
      };
    };

    # iTerm2 is installed via Homebrew (GUI app with native macOS integration)
    # Nothing to configure here for Nix - it's in the Homebrew casks

    # Terminal-related packages from Nix
    home.packages = with pkgs; [
      # Terminal multiplexer
      zellij              # Modern tmux alternative in Rust
      # tmux              # Uncomment if preferred
      
      # Terminal utilities
      reattach-to-user-namespace  # For tmux on macOS
    ];
  };
}
