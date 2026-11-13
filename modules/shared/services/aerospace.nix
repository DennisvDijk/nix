{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aerospace
  ];

  # nix-darwin only runs a fixed set of activation script names. This text is
  # kept (and is now a valid submodule) but is not executed, matching the
  # previous configuration. Append it to `postActivation.text` to actually
  # install the toml on switch.
  system.activationScripts.aerospace.text = ''
    mkdir -p ~/.config/aerospace
    cp ${./../../config/aerospace.toml} ~/.config/aerospace/aerospace.toml
  '';
}
