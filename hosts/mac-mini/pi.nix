# Pi coding agent, pinned.
# The project is Mario Zechner's pi-mono (https://pi.dev/, github.com/badlogic/pi-mono).
# The npm name moved from @mariozechner/pi-coding-agent to @earendil-works/pi-coding-agent.
# 1.5.2 is the version Homebrew's pi-coding-agent formula installs.
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

  # The published tarball has no lockfile. This one was generated with
  # `npm install --package-lock-only --ignore-scripts` against that tarball.
  postPatch = ''
    cp ${./pi-package-lock.json} package-lock.json
  '';

  meta = {
    description = "Pi coding agent";
    homepage = "https://pi.dev/";
    mainProgram = "pi";
  };
}
