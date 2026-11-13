# Pi on the Mac mini

- Default model: `opencode-go/deepseek-v4-flash`.
- Tools on PATH: `git`, `gh`, `rg`, `fd`, `jq`, `tmux`, `docker`.
- Docker is Colima. The socket is `$HOME/.colima/default/docker.sock`.
- Prefer small diffs. Do not start GUI apps; this machine is headless.
- `pi-up` in zsh attaches a tmux session named `pi`, so an SSH drop does not kill it.
