# worktrunk 0.81.0 (binary `wt`), the version nixpkgs documents for this era.
# Official Apple Silicon release. The locked nixpkgs has no pkgs.worktrunk.
{ pkgs }:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "worktrunk";
  version = "0.81.0";

  src = pkgs.fetchurl {
    url = "https://github.com/max-sixty/worktrunk/releases/download/v${version}/worktrunk-aarch64-apple-darwin.tar.xz";
    hash = "sha256-ucPy+AcVVM+IUARm1l014YrV7a1XYkeaHxS83dWreII=";
  };

  sourceRoot = "worktrunk-aarch64-apple-darwin";

  installPhase = ''
    mkdir -p "$out/bin"
    install -m755 wt "$out/bin/wt"
    install -m755 git-wt "$out/bin/git-wt"
  '';

  meta = {
    description = "Git worktrees for parallel coding agents";
    homepage = "https://worktrunk.dev";
    mainProgram = "wt";
    platforms = [ "aarch64-darwin" ];
  };
}
