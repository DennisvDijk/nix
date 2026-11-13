# nix-config

nix-darwin and Home Manager for Dennis van Dijk's Macs. One flake, four hosts, all `aarch64-darwin`.

| Host | What it is | macOS user |
| --- | --- | --- |
| `personal` | Personal MacBook | `dennisvandijk` |
| `work` | Work laptop (Enexis) | `Dennis.van.Dijk` |
| `mac-mini` | Headless server: Colima and Pi. No GUI apps | `dennisvandijk` |
| `template` | Starting point for another Mac | `dennisvandijk` |

Dotfiles for the laptops live in `hosts/<host>/dotfiles`. The mini has its own small tree at `hosts/mac-mini/dotfiles` (`~/.zshrc` and `~/.pi`). Home Manager symlinks them from the checkout at `my.flakePath` (default `~/.config/nix`), so they stay writable. Secrets are sops-encrypted in `secrets/`. Get Shit Done is not installed.

The mini runs Colima as a LaunchDaemon (boot, as `dennisvandijk`, no GUI login) and Pi 1.5.2 from nix. Tailscale is nix-darwin's `services.tailscale` (`tailscaled` at boot), not the `tailscale-app` cask. After the first switch, run `sudo tailscale up` once (add `--ssh` if you want Tailscale SSH). `just mini-docker-status` and `just mini-pi` are meant to be run on that machine. SSH, never-sleep, restart after power failure, and a nightly `nix-collect-garbage` plus `nix-store --optimise` are part of the Darwin config. Nix GC is a LaunchDaemon because Determinate Nix keeps `nix.enable = false`, and nix-darwin will not install its own GC job in that case.

## Everyday commands

`just` is the front door. `nix develop` puts it on your PATH. With no arguments it lists every recipe. The host defaults to `$NIX_HOST`, then `personal`.

```bash
just                  # list recipes
just personal         # darwin-rebuild, then home-manager, for that host
just work
just mac-mini         # switch the mini
just mini-docker-status
just mini-pi          # tmux session named pi; run on the mini
just agent feat/auth  # wt switch --create, then cmux + pi (laptops)
just agents           # wt list
just agent-remove feat/auth
just steer            # cmux paste --submit, from stdin
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

## Agent stack (personal and work)

`my.features.ai.agentStack.enable` installs Pi 1.5.2, OpenCode 2.3.0, and worktrunk (`wt`) from pins in this repo. The locked nixpkgs has neither current package (`opencode` there is 1.1.47). GitHub's latest release tag is still v1.19.5; 2.3.0 is the current v2 tag. cmux stays the Homebrew cask it already was. The mini does not get this option: tmux (`just mini-pi`) already keeps a Pi session across an SSH drop, and herdr would be a second multiplexer.

Nix links the thin OpenCode file (`providers`, `permissions`, `mcp`, `$schema` `https://opencode.ai/config.json`) and, for Pi, `settings.json` plus `models.json`. A few hand-written files are linked too: the ketch extension, permission and optimizer configs, AGENTS/SETUP notes, personal `trust.json`, work `web-search.json`, the Headroom `.env.example`, `cli.json` (was `tui.json`), and the neon-singularity theme. Skills, the other themes, sessions, and caches stay out of the repo. Personal Pi stays `opencode-go/deepseek-v4-flash` with oMLX at `http://127.0.0.1:8000/v1`. Work Pi stays `ai-gateway/gpt-5.6-luna`. `npm:pi-worktrunk` is the only extra package in the laptop settings. The cmux hook is not vendored: `just agent-setup` runs `cmux hooks setup pi`, which writes it under `~/.pi`. `~/.config/worktrunk/config.toml` only sets `worktree-path`.

One-time on each laptop, after `just home`:

- `pi` downloads the packages listed in `settings.json`, including `pi-worktrunk`, on first launch.
- macOS will ask for cmux's Automation permission the first time `just agent` opens a workspace.
- `just agent-setup` re-runs `wt config shell install`, `wt config create`, and `cmux hooks setup pi` if you want the generators instead of the files in this repo. `wt config plugins pi install` is optional and not run.

## Voice

TypeWhisper and Handy are both installed on the laptops. TypeWhisper is the dictation front-end. There is no checked-in TypeWhisper config: the app does not document a file this repo can own. On each Mac, once:

1. System Settings → Privacy & Security → Microphone, and Accessibility, allow TypeWhisper.
2. In TypeWhisper, pick the local Parakeet TDT v3 engine for English and Dutch. Leave WhisperKit available if you want streaming.
3. Dictate into the focused cmux pane. That is the reliable way to talk to Pi.
4. Do not point TypeWhisper at Headroom (`:8787`) until that API is confirmed.

A voice-command router (dictate vs Mac command vs new agent) is not installed. TypeWhisper workflows can call a local model, but the workflow format was not verified here, so it is not declared. To steer the focused Pi pane from a script: `just steer`. To open a new task: `just agent <branch>`.

Whether Handy is redundant next to TypeWhisper is an open question. Both stay installed.

## Notes that are easy to miss

- Nix itself is `nix.enable = false` because these Macs run Determinate Nix.
- `~/.zshrc` is a symlink into the checkout, so Home Manager does not generate a second one. The zsh package is still installed.
- Personal Home Manager also installs `~/.config/sketchybar/sketchybarrc` and `workspace_update.sh` from `modules/config/sketchybar`. Those two are copies in the Nix store. SketchyBar rewrites its own config through them poorly, which is why the other dotfiles are checkout symlinks instead.
- AeroSpace has one config, `~/.aerospace.toml`, on the laptops. The mini does not run AeroSpace.
- `modules/config/Dracula.itermcolors` is not applied. iTerm only imports that file when you open it, and writing the preference plist would override the current profile.
- `skills-lock.json` is a pi-agent skills lock. The flake does not read it.
- On a Mac that already has chezmoi's copies, the first `just home` replaces those regular files (`force = true`) and leaves a backup. Then delete `~/.local/share/chezmoi` and `~/.config/chezmoi`.
