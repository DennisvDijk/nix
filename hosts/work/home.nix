{ config, pkgs, lib, username, hostName, ... }:

{
  imports = [
    ../../modules/shared/home-manager.nix  # Base config with core packages
    ../../modules/home/features            # Feature system
  ];

  # Host identification
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.05";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Feature flags configuration - minimal for work
  my.features = {
    # Core (enabled by default via features/default.nix)
    shell = {
      enable = true;
      starship.enable = true;
      direnv.enable = true;
      zoxide.enable = true;
      atuin.enable = false;  # Not needed for work
    };
    
    git = {
      enable = true;
      userName = "Dennis van Dijk";
      userEmail = "dennis@work.example.com";  # Override with real work email
      delta.enable = true;
      lazygit.enable = true;
      jujutsu.enable = false;
      githubCli.enable = true;
    };
    
    terminal = {
      enable = true;
      wezterm.enable = true;
      alacritty.enable = false;
      kitty.enable = false;
      iterm2.enable = true;
    };
    
    # Disable heavy personal features
    ai.enable = false;
    dev.enable = false;
    k8s.enable = false;
    nh.enable = false;
    openclaw.enable = false;
    devtools.enable = false;
  };

  # User identity configuration
  my.user = {
    fullName = "Dennis van Dijk";
    firstName = "Dennis";
    lastName = "van Dijk";
    email.personal = "dennis@thenextgen.nl";
    email.git = "dennis@work.example.com";
    email.work = "dennis@work.example.com";
    username = username;
    homeDirectory = "/Users/${username}";
  };

  # Work-specific environment variables
  programs.zsh.initContent = lib.mkAfter ''
    export WORK_ENV=1
    export NIX_HOST="${hostName}"
  '';

  # Work-specific packages (optional - add as needed)
  # home.packages = with pkgs; [ ];
}
