# Front door for this Nix config.
# Hosts: personal, work, mac-mini, template
# The host argument defaults to $NIX_HOST, then personal.
#
#   just                  list recipes
#   just personal         switch Darwin and Home Manager for that host
#   just diff work        show what a Darwin switch would change

host := env_var_or_default("NIX_HOST", "personal")

# List every recipe
[private]
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

# personal, work, mac-mini, and template are shortcuts for `just all <host>`
personal:
    just all personal

work:
    just all work

mac-mini:
    just all mac-mini

template:
    just all template

# Package diff between the running Darwin system and this flake
diff host=host:
    #!/usr/bin/env bash
    set -euo pipefail
    new=$(nix build ".#darwinConfigurations.{{host}}.system" --print-out-paths --no-link)
    if [[ -e /run/current-system ]]; then
      nix store diff-closures /run/current-system "$new"
    else
      echo "Built $new"
      echo "No /run/current-system on this machine, so there is nothing to diff."
    fi

# Same idea for Home Manager, against the current home-manager profile
diff-home host=host:
    #!/usr/bin/env bash
    set -euo pipefail
    new=$(nix build ".#homeConfigurations.{{host}}.activationPackage" --print-out-paths --no-link)
    profile="${HOME}/.local/state/nix/profiles/home-manager"
    if [[ -e "$profile" ]]; then
      nix store diff-closures "$profile" "$new"
    else
      echo "Built $new"
      echo "No Home Manager profile at $profile yet."
    fi

# Drop generations older than 7 days. Does not touch the current system.
gc:
    nix-collect-garbage --delete-older-than 7d

# Roll the Darwin system back one generation and activate it
rollback:
    sudo darwin-rebuild switch --rollback

# Roll the Home Manager profile back one generation
rollback-home:
    #!/usr/bin/env bash
    set -euo pipefail
    profile="${HOME}/.local/state/nix/profiles/home-manager"
    nix profile rollback --profile "$profile"

# Update flake.lock
update:
    nix flake update

# Format Nix files (nixfmt, RFC 166)
fmt:
    nix fmt

# Run deadnix and statix
check:
    nix flake check

# Evaluate every host without building. Prints the system and home paths.
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
