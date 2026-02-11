# modules/home/features/nh.nix
# nh - Nix helper for easier darwin/home-manager switching

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.features.nh;
in
{
  options.my.features.nh = {
    enable = mkEnableOption "nh - Nix helper for easier system management";
    
    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/nix";
      description = "Path to the Nix flake directory";
    };
    
    defaultDarwinHost = lib.mkOption {
      type = lib.types.str;
      default = "personal";
      description = "Default Darwin host to use with nh";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nh
    ];

    # Environment variable for nh
    home.sessionVariables = {
      FLAKE = cfg.flakeDir;
    };

    # Shell aliases for nh
    programs.zsh.shellAliases = {
      # Darwin switching
      nd = "nh darwin switch";
      ndb = "nh darwin switch --flake ${cfg.flakeDir}#${cfg.defaultDarwinHost}";
      ndu = "nh darwin switch --update";
      
      # Home Manager switching  
      nhs = "nh home switch";
      nhb = "nh home switch --flake ${cfg.flakeDir}#${cfg.defaultDarwinHost}";
      
      # Nix operations
      ns = "nh search";
      nx = "nix-shell -p";
      
      # Cleaning
      ngc = "nh clean all --keep-since 7d --keep 5";
      ngca = "nh clean all";
      
      # Development
      nf = "cd ${cfg.flakeDir}";
      nfu = "nix flake update --flake ${cfg.flakeDir}";
    };

    # Additional shell functions
    programs.zsh.initExtra = ''
      # Nix flake helpers
      nix-check() {
        echo "Checking flake..."
        nix flake check --flake ${cfg.flakeDir}
      }
      
      nix-fmt() {
        nix fmt ${cfg.flakeDir}
      }
      
      # Quick switch with host selection
      nd-switch() {
        local host=''${1:-${cfg.defaultDarwinHost}}
        nh darwin switch --flake ${cfg.flakeDir}#$host
      }
      
      nh-switch() {
        local host=''${1:-${cfg.defaultDarwinHost}}
        nh home switch --flake ${cfg.flakeDir}#$host
      }
    '';
  };
}
