{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/home-manager.nix
  ];

  # SOPS configuration (optioneel - uncomment als je work-specifieke secrets wilt)
  # sops = {
  #   age.keyFile = "/Users/dennisvandijk/Library/Application Support/sops/age/keys.txt";
  #   defaultSopsFile = ../../secrets/work-secrets.yaml;
  #   secrets = {
  #     work_api_key = {};
  #   };
  # };

  # Work-specific environment variables
  programs.zsh.initContent = lib.mkAfter ''
    export WORK_ENV=1
    export NIX_HOST="work"
    export COMPANY_DOMAIN="work.example.com"
  '';

  # Work-specific packages (none at the moment, but can add here)
  # home.packages = with pkgs; [ ];
}
