# Day-to-day commands for this Nix config.
# Hosts: personal, work, mac-mini, template
# Default host is $NIX_HOST, or personal.

host := env_var_or_default("NIX_HOST", "personal")

# Show available recipes
default:
    @just --list

# Rebuild and switch the Darwin system. Usage: just switch [host]
switch host=host:
    sudo darwin-rebuild switch --flake .#{{host}}

# Switch Home Manager. Usage: just home [host]
home host=host:
    home-manager switch --flake .#{{host}}

# Switch Darwin, then Home Manager
all host=host: (switch host) (home host)

# Update flake.lock
update:
    nix flake update

# Format Nix files (nixfmt, RFC 166)
fmt:
    nix fmt

# Run deadnix and statix
check:
    nix flake check

# Evaluate every host (no build). Prints system and home-manager paths.
eval:
    #!/usr/bin/env bash
    set -euo pipefail
    for name in personal work mac-mini template; do
      printf '%s darwin  ' "$name"
      nix eval --raw ".#darwinConfigurations.${name}.config.system.build.toplevel.outPath"
      printf '\n%s home    ' "$name"
      nix eval --raw ".#homeConfigurations.${name}.activationPackage.outPath"
      printf '\n'
    done
