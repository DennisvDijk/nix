# AeroSpace package plus the managed config.
# nix-darwin only executes a fixed set of activation script names, so the
# copy is appended to postActivation (the hook that actually runs).
{
  pkgs,
  lib,
  username,
  ...
}:
{
  environment.systemPackages = [ pkgs.aerospace ];

  system.activationScripts.postActivation.text = lib.mkAfter ''
    # Activation runs as root; write the user's config, not /var/root.
    dest="/Users/${username}/.config/aerospace"
    ${pkgs.coreutils}/bin/install -d -o ${username} -g staff -m 755 "$dest"
    ${pkgs.coreutils}/bin/install -o ${username} -g staff -m 644 \
      ${../../config/aerospace.toml} "$dest/aerospace.toml"
  '';
}
