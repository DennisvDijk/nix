# nix-config

nix-darwin and Home Manager for Dennis van Dijk's Macs. One flake, four hosts, all `aarch64-darwin`.

| Host | What it is | macOS user |
| --- | --- | --- |
| `personal` | Personal MacBook | `dennisvandijk` |
| `work` | Work laptop (Enexis) | `Dennis.van.Dijk` |
| `mac-mini` | Headless home server. Reuses the personal chezmoi source | `dennisvandijk` |
| `template` | Starting point for another Mac | `dennisvandijk` |

Dotfiles are applied by chezmoi from `hosts/<host>/dotfiles` (the mini points at the personal tree). Secrets are sops-encrypted in `secrets/`.

## Everyday commands

From a checkout of this repo, with flakes enabled:

```bash
just switch personal     # sudo darwin-rebuild switch --flake .#personal
just home personal       # home-manager switch --flake .#personal
just all work            # both, for the work host
just update              # nix flake update
just fmt                 # nix fmt  (nixfmt, RFC 166)
just check               # nix flake check  (deadnix + statix)
```

`just` is in the devshell (`nix develop`). The same commands exist as flake apps: `nix run .#switch -- personal`, `nix run .#home -- work`, `nix run .#fmt`, `nix run .#update`, `nix run .#check`.

The host defaults to `$NIX_HOST`, then `personal`.

## Layout

```
flake.nix                 inputs, formatter, checks, devshell, apps
lib/hosts.nix             host registry (username + constructors)
hosts/<name>/darwin.nix   what differs on that Mac
hosts/<name>/home.nix     what differs for that user
modules/darwin/common.nix user, caches, Homebrew cleanup
modules/darwin/features/  macOS defaults, Homebrew baseline, oMLX
modules/home/common.nix   Home Manager baseline for real hosts
modules/home/features/    shell, cli, git, dev, k8s, ai, terminals, nh
modules/shared/           packages every home gets, plus a few services
```

Host files set overrides only. Feature modules own the option definitions (`lib.mkEnableOption` / `lib.mkOption`) and the package lists. A flag left unset keeps its default.

`modules/home/common.nix` is for machines that are in use. The template home config does not import it.

## Add a host

1. Add a username in `lib/hosts.nix`.
2. Copy `hosts/template/` to `hosts/<name>/`.
3. Set `networking` overrides and `my.features` / Homebrew extras in the new files.
4. `just switch <name>` and `just home <name>`.

## Add a package

- Every host: `modules/shared/home-manager.nix` (`home.packages`).
- One feature (git, k8s, ai, …): the module in `modules/home/features/`.
- One host: `home.packages` in `hosts/<name>/home.nix`, or `homebrew.casks` / `homebrew.brews` in `hosts/<name>/darwin.nix` for Mac apps.
- A new toggle: add `lib.mkEnableOption` in a feature module and set it from the host.

Search first: `./bin/search_package.sh <name>`.

## Notes that are easy to miss

- Nix itself is `nix.enable = false` because these Macs run Determinate Nix.
- chezmoi owns `~/.zshrc`, so Home Manager's zsh *config* is off. The zsh package is still installed.
- `mac-app-util` keeps its own nixpkgs pin (it needs a specific SBCL and dockutil). The other inputs follow this flake's nixpkgs.
- `modules/home/apps/orion.nix`, `modules/home/apps/vscode/extensions.nix`, and `modules/home/darwin/casks.nix` are not imported. They are still in the tree so those settings are not thrown away.
- `modules/config/sketchybar/` and `modules/config/Dracula.itermcolors` are not wired into a module. SketchyBar on the personal Mac is installed, but its rc is not deployed by Nix. Aerospace's toml copy on the mini is a valid activation script and, as before, nix-darwin does not run custom script names.
- `skills-lock.json` is a pi-agent skills lock. The flake does not read it.
- The `get-shit-done` trees under both chezmoi sources are identical vendored app data. They are what GitHub used to count as JavaScript. `.gitattributes` marks them vendored. They are still deployed.
