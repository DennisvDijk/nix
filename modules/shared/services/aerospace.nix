{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aerospace
  ];

  # Aerospace configuration
  system.activationScripts.aerospace = ''
    mkdir -p ~/.config/aerospace
    cp ${./../../config/aerospace.toml} ~/.config/aerospace/aerospace.toml
  '';
}