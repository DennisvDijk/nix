# Pi coding agent, pinned to 1.5.2.
# Mario Zechner's pi-mono (https://pi.dev, github.com/badlogic/pi-mono).
# Published as @earendil-works/pi-coding-agent. The previous npm name
# @mariozechner/pi-coding-agent stops at 0.73.1.
# The locked nixpkgs does not have pkgs.pi-coding-agent yet, so this
# derivation is the pin. 1.5.2 is what Homebrew's formula installs and
# is above the 0.99.1 floor for pi-worktrunk.
{ pkgs }:
pkgs.buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "1.5.2";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-aRveGGJztFfZ0cQdD9R7V4U7XoXe0a3Rofa3jmbCYfQ=";
  };

  npmDepsHash = "sha256-TRZSUsB4CelLNm8gXbv9ghrEqUiXaczURJxDx3NXcO8=";
  dontNpmBuild = true;

  # The published tarball has no lockfile.
  postPatch = ''
    cp ${./pi-package-lock.json} package-lock.json
  '';

  meta = {
    description = "Pi coding agent";
    homepage = "https://pi.dev/";
    mainProgram = "pi";
  };
}
