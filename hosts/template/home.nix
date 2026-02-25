{ config, pkgs, lib, username, hostName, ... }:

{
  imports = [
    ../../modules/shared/home-manager.nix  # Base config (core packages)
    ../../modules/home/features             # Feature system (disabled by default)
  ];

  # Host identification (provided by flake via specialArgs)
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # =============================================================================
  # FEATURE FLAGS - Customize for this machine
  # =============================================================================
  # Set enable = true for features you want, false for those you don't
  # All features are disabled by default - enable what you need!
  # =============================================================================
  
  my.features = {
    # Core - DISABLED by default, enable in your host config
    shell = {
      enable = false;
      # starship.enable = false;
      # direnv.enable = false;
      # zoxide.enable = false;
      # atuin.enable = false;
    };
    
    # cli = false;  # Core CLI tools
    
    # git = false;   # Git configuration
    
    # terminal = false;  # Terminal emulators
    
    # nh = false;   # Nix home manager helper
    
    # dev = false;  # Development tools (docker, node, python)
    
    # k8s = false;  # Kubernetes tools
    
    # ai = false;   # AI/ML tooling
    
    # openclaw = false;  # OpenClaw AI assistant
    
    # devtools = false;  # OpenCode DevTools
  };

  # =============================================================================
  # USER IDENTITY - Customize for this machine
  # =============================================================================
  my.user = {
    fullName = "Your Name";
    firstName = "Your";
    lastName = "Name";
    email.personal = "you@example.com";
    email.git = "you@example.com";
    email.work = "";
    username = username;
    homeDirectory = "/Users/${username}";
  };

  # =============================================================================
  # HOST-SPECIFIC CONFIGURATION
  # =============================================================================
  
  # Environment variables for this host
  # programs.zsh.initContent = lib.mkAfter ''
  #   export MY_VAR=value
  # '';

  # Host-specific packages (beyond core)
  # home.packages = with pkgs; [
  #   # Add packages here
  # ];

  # =============================================================================
  # OPTIONAL: SOPS secrets (uncomment and configure)
  # =============================================================================
  # sops = {
  #   age.keyFile = "/Users/${username}/Library/Application Support/sops/age/keys.txt";
  #   defaultSopsFile = ../../secrets/${hostName}-secrets.yaml;
  #   secrets = {
  #     # Add secrets here
  #   };
  # };
}
