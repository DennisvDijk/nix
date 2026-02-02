{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/shared/home-manager.nix
    ../../modules/home/openclaw.nix
  ];

  # SOPS configuration for secret management
  sops = {
    # Pad naar je age private key (macOS specifiek!)
    age.keyFile = "/Users/dennisvandijk/Library/Application Support/sops/age/keys.txt";
    
    # Standaard secrets file
    defaultSopsFile = ../../secrets/example.yaml;
    
    # Definieer welke secrets je wilt gebruiken
    secrets = {
      # Dit maakt het secret beschikbaar via: config.sops.secrets.openclaw_api_key.path
      openclaw_api_key = {};
      
      # Je kunt ook andere secrets toevoegen:
      # database_password = {};
      # "services/github/token" = {};  # voor nested keys
    };
  };

  # Personal-specific environment variable
  programs.zsh.initContent = lib.mkAfter ''
    export PERSONAL_ENV=1
    export NIX_HOST="personal"
  '';

  # Personal-specific packages
  home.packages = with pkgs; [
    ffmpeg
    imagemagick
  ];
}
