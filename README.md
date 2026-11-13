# nix-config

nix-darwin and Home Manager for Dennis van Dijk's Macs. One flake, four hosts, all `aarch64-darwin`.

| Host | What it is | macOS user |
| --- | --- | --- |
| `personal` | Personal MacBook | `dennisvandijk` |
| `work` | Work laptop (Enexis) | `Dennis.van.Dijk` |
| `mac-mini` | Headless home server. Uses the personal dotfiles | `dennisvandijk` |
| `template` | Starting point for another Mac | `dennisvandijk` |

Dotfiles live in `hosts/<host>/dotfiles` (the mini uses the personal tree). Home Manager symlinks them from the checkout at `my.flakePath` (default `~/.config/nix`), so they stay writable. The get-shit-done tree is shared at `dotfiles/get-shit-done`. Secrets are sops-encrypted in `secrets/`.

## Everyday commands

`just` is the front door. `nix develop` puts it on your PATH. With no arguments it lists every recipe. The host defaults to `$NIX_HOST`, then `personal`.

```bash
just                  # list recipes
just personal         # darwin-rebuild, then home-manager, for that host
just work
just mac-mini
just diff             # what a Darwin switch would change vs /run/current-system
just diff-home work
just gc               # nix-collect-garbage --delete-older-than 7d
just rollback         # previous Darwin generation
just rollback-home    # previous Home Manager generation
just links            # check dotfile symlinks point at this checkout
just update           # nix flake update
just fmt              # nix fmt (nixfmt, RFC 166)
just check            # deadnix + statix
```

`just switch personal` and `just home personal` are the two halves of `just personal`. The same switch, home, update, fmt, and check commands exist as `nix run .#switch -- personal` and so on.

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
- `~/.zshrc` is a symlink into the checkout, so Home Manager does not generate a second one. The zsh package is still installed.
- `mac-app-util` keeps its own nixpkgs pin (it needs a specific SBCL and dockutil). The other inputs follow this flake's nixpkgs.
- Personal Home Manager also installs `~/.config/sketchybar/sketchybarrc` and `workspace_update.sh` from `modules/config/sketchybar`. Those two are copies in the Nix store. SketchyBar rewrites its own config through them poorly, which is why the other dotfiles are checkout symlinks instead.
- AeroSpace has one config, `~/.aerospace.toml`. Personal and the mini share the personal file. Work has its own.
- `modules/config/Dracula.itermcolors` is not applied. iTerm only imports that file when you open it, and writing the preference plist would override the current profile.
- `skills-lock.json` is a pi-agent skills lock. The flake does not read it.
- On a Mac that already has chezmoi's copies, the first `just home` replaces those regular files (`force = true`) and leaves a backup. Then delete `~/.local/share/chezmoi` and `~/.config/chezmoi`.
