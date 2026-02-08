# modules/home/features/shell.nix
# Shell environment with zsh, starship, direnv, zoxide

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.features.shell;
in
{
  options.my.features.shell = {
    enable = mkEnableOption "shell environment (zsh, starship, direnv, zoxide)";
    
    # Sub-options for fine-grained control
    starship.enable = mkEnableOption "starship prompt" // { default = true; };
    direnv.enable = mkEnableOption "direnv with nix-direnv" // { default = true; };
    zoxide.enable = mkEnableOption "zoxide smart cd" // { default = true; };
    atuin.enable = mkEnableOption "atuin shell history" // { default = true; };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        size = 100000;
        save = 100000;
        share = true;
        ignoreDups = true;
        ignoreSpace = true;
      };
    };

    programs.starship = mkIf cfg.starship.enable {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        line_break.disabled = true;
        kubernetes.disabled = false;
        git_status.disabled = false;
        directory.truncate_to_repo = true;
        cmd_duration = {
          min_time = 500;
          format = " took [$duration]($style)";
        };
      };
    };

    programs.direnv = mkIf cfg.direnv.enable {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.load_dotenv = true;
      };
    };

    programs.zoxide = mkIf cfg.zoxide.enable {
      enable = true;
      enableZshIntegration = true;
    };

    programs.atuin = mkIf cfg.atuin.enable {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        search_mode = "fuzzy";
        filter_mode = "global";
      };
    };

    # Core shell utilities as Nix packages (not Homebrew)
    home.packages = with pkgs; [
      # These should be in Nix, not Homebrew for reproducibility
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];
  };
}
