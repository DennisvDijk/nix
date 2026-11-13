# OpenCode CLI 1.19.5, the current GitHub release.
# The locked nixpkgs copy is 1.1.47, which is behind that release.
# Official Apple Silicon zip. This Linux runner cannot execute the binary.
{ pkgs }:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "opencode";
  version = "1.19.5";

  src = pkgs.fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
    hash = "sha256-wcnmJSEZIZLvTD7RNVraIUQFW922FoIhfpl7A8VSA8E=";
  };

  nativeBuildInputs = [ pkgs.unzip ];

  unpackPhase = ''
    unzip -q "$src" -d .
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    install -m755 opencode "$out/bin/opencode"
  '';

  meta = {
    description = "OpenCode terminal coding agent";
    homepage = "https://opencode.ai/";
    mainProgram = "opencode";
    platforms = [ "aarch64-darwin" ];
  };
}
