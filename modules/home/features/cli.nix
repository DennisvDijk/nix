# modules/home/features/cli.nix
# Core CLI quality-of-life tools - ALL from Nix, not Homebrew

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.my.features.cli;
in
{
  options.my.features.cli = {
    enable = mkEnableOption "core CLI tools";
    
    # Optional sub-features
    modernReplacements.enable = mkEnableOption "modern CLI alternatives (eza, bat, fd, ripgrep)" // { default = true; };
    fileTools.enable = mkEnableOption "file management tools" // { default = true; };
    systemTools.enable = mkEnableOption "system monitoring tools" // { default = true; };
  };

  config = mkIf cfg.enable {
    # FZF is essential
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
      defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
    };

    # Modern CLI replacements (from Nix, not Homebrew!)
    programs.bat = mkIf cfg.modernReplacements.enable {
      enable = true;
      config = {
        theme = "catppuccin-mocha";
        style = "numbers,changes,header";
      };
    };

    programs.eza = mkIf cfg.modernReplacements.enable {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [ 
        "--group-directories-first" 
        "--header" 
      ];
    };

    # Tealdeer for tldr
    programs.tealdeer = {
      enable = true;
      settings = {
        display = {
          compact = false;
          use_pager = false;
        };
        updates = {
          auto_update = true;
          auto_update_interval_hours = 168;  # Weekly
        };
      };
    };

    home.packages = mkMerge [
      (mkIf cfg.modernReplacements.enable (with pkgs; [
        # Core modern tools (from Nix!)
        fd                # Better find
        ripgrep           # Better grep
        sd                # Better sed
        procs             # Better ps
        dust              # Better du
        duf               # Better df
        bottom            # Better top/htop
        gping             # Better ping with graph
        doggo             # Better dig
      ]))
      
      (mkIf cfg.fileTools.enable (with pkgs; [
        # File management
        tree
        p7zip
        unzip
        unrar
        rsync
        rclone
        fd                # Already listed above but good for clarity
      ]))
      
      (mkIf cfg.systemTools.enable (with pkgs; [
        # System monitoring
        fastfetch
        htop              # Fallback to bottom
        iotop
        nethogs
      ]))
      
      (with pkgs; [
        # JSON/YAML/TOML processing
        jq
        yq-go
        fx                # Interactive JSON viewer
        
        # Archives
        xz
        bzip2
        
        # Text processing
        delta             # For git (also in git module)
        glow              # Markdown viewer
        
        # macOS specific
        m-cli             # macOS command line tools
      ])
    ];
  };
}
