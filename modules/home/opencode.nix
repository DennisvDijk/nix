# OpenCode CLI 2.3.0, the current v2 GitHub release.
# GitHub's "latest" release is still v1.19.5. The locked nixpkgs copy is 1.1.47.
# Official Apple Silicon zip. This Linux runner cannot execute the binary.
{ pkgs }:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "opencode";
  version = "2.3.0";

  src = pkgs.fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
    hash = "sha256-eQffKxJyCoQPu0nFuXi5uCkltr91R5pf0havqJMrZwI=";
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
