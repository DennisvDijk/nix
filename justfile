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

# Colima and the Docker socket. Run this on the mini.
mini-docker-status:
    #!/usr/bin/env bash
    set -euo pipefail
    colima status
    docker info

# Attach the pi coding session, creating it if SSH dropped it.
mini-pi:
    tmux new-session -A -s pi pi

# Create a worktree and open pi in a new cmux workspace. Run on a laptop.
# Usage: just agent feat/auth
agent branch:
    #!/usr/bin/env bash
    set -euo pipefail
    wt switch --create "{{branch}}"
    cwd="$(git worktree list --porcelain | awk -v b="{{branch}}" '
      $1=="worktree"{p=$2}
      $1=="branch" && $2=="refs/heads/"b {print p; exit}
    ')"
    if [[ -z "${cwd}" ]]; then
      echo "No worktree found for branch {{branch}}" >&2
      exit 1
    fi
    cmux new-workspace --cwd "$cwd" --command pi

# List worktrunk worktrees.
agents:
    wt list

# Remove one worktrunk worktree. Usage: just agent-remove feat/auth
agent-remove branch:
    wt remove "{{branch}}"

# Paste stdin into the focused cmux terminal and submit it.
steer:
    #!/usr/bin/env bash
    set -euo pipefail
    cmux paste --submit

# One-time: shell hook, worktrunk user config, cmux's Pi extension.
# The shell line and config.toml are already in this repo; this refreshes
# them from the installed cmux and wt if you want their latest generators.
agent-setup:
    wt config shell install
    wt config create
    cmux hooks setup pi
    @echo "Pi >= 0.99.1: pi install npm:pi-worktrunk (also listed in settings.json packages)"

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

# Show dotfile symlinks for HOST and whether they resolve into the checkout.
links host=host:
    #!/usr/bin/env bash
    set -euo pipefail
    flake="${FLAKE_PATH:-$HOME/.config/nix}"
    missing=0
    while IFS= read -r rel; do
      [[ -z "$rel" ]] && continue
      target="$HOME/$rel"
      if [[ -L "$target" ]]; then
        dest="$target"
        for _ in 1 2 3 4 5 6; do
          [[ -L "$dest" ]] || break
          next=$(readlink "$dest")
          case "$next" in
            /*) dest="$next" ;;
            *) dest="$(cd "$(dirname "$dest")" && pwd)/$next" ;;
          esac
        done
        case "$dest" in
          "$flake"/*) printf 'ok   %s\n' "$rel" ;;
          *) printf '??   %s -> %s\n' "$rel" "$dest" ;;
        esac
      elif [[ -e "$target" ]]; then
        printf 'file %s (not a symlink yet)\n' "$rel"
        missing=1
      else
        printf 'miss %s\n' "$rel"
        missing=1
      fi
    done < <(nix eval --raw ".#homeConfigurations.{{host}}.config.home.file" --apply 'files: builtins.concatStringsSep "\n" (builtins.attrNames files)')
    exit "$missing"

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
