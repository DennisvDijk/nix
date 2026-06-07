{ config, pkgs, lib, ... }:

let
  omlx-app = pkgs.stdenv.mkDerivation rec {
    pname = "omlx-app";
    version = "0.4.2rc1";

    src = pkgs.fetchurl {
      url = "https://github.com/jundot/omlx/releases/download/v0.4.2rc1";
      sha256 = "1xb3ziyz2608nqv5pfvywkpxlsjps1x1pdz03mivykdcwc8185ya";
    };

    # hdiutil requires macOS system services; disable sandbox for this derivation
    __noChroot = true;

    buildInputs = [ pkgs.rsync ];

    buildPhase = ''
      mnt=$(mktemp -d)
      /usr/bin/hdiutil attach -readonly -nobrowse -mountpoint "$mnt" "$src"
      mkdir -p "$out/Applications"
      cp -R "$mnt/oMLX.app" "$out/Applications/"
      /usr/bin/hdiutil detach "$mnt"
      rmdir "$mnt"
    '';

    dontUnpack = true;
    dontConfigure = true;
    dontInstall = true;

    meta = {
      description = "oMLX - LLM inference server with native macOS UI";
      homepage = "https://github.com/jundot/omlx";
      platforms = [ "aarch64-darwin" ];
    };
  };
in
{
  options.my.darwin.omlx-app = {
    # Disabled by default: upstream release URL is broken (missing asset filename)
    # and fetching fails on corporate networks with SSL inspection.
    # Enable manually per-host once the derivation URL is fixed.
    enable = lib.mkEnableOption "oMLX macOS app (.dmg) managed via Nix";
  };

  config = lib.mkIf config.my.darwin.omlx-app.enable {
    # Copy the .app bundle to /Applications/ on first install only.
    # After that, Sparkle (built-in auto-updater) handles upgrades.
    # If you ever need to force a reinstall from Nix, delete
    # /Applications/oMLX.app and run darwin-rebuild switch.
    system.activationScripts.applications.text = lib.mkAfter ''
      if [ ! -d "/Applications/oMLX.app" ]; then
        echo "Installing oMLX.app to /Applications..."
        ${pkgs.rsync}/bin/rsync -a --delete "${omlx-app}/Applications/oMLX.app/" "/Applications/oMLX.app/"
      fi
    '';
  };
}
