# hosts/work/home.nix
# Work host home configuration — Enexis AI Platform

{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  imports = [ ../../modules/home/common.nix ];

  # Enexis AI Platform. Only the overrides; module defaults cover the rest.
  my.features = {
    shell = {
      # chezmoi owns ~/.zshrc, starship.toml, and atuin/config.toml.
      starship.enable = false;
      atuin.enable = false;
    };

    git = {
      userName = "Dennis van Dijk";
      userEmail = null; # SOPS writes ~/.gitconfig.local
      githubCli.enable = false; # Work uses GitLab, not GitHub
      gitlabCli.enable = true;
    };

    terminal.alacritty.enable = false;

    nh.defaultDarwinHost = "work";

    dev.enable = true;

    k8s = {
      enable = true;
      cloud.enable = true; # awscli2, azure-cli, sops, age — via Nix, not brew
    };

    ai = {
      enable = true;
      localLLMs.enable = false; # data residency + RAM
    };
  };

  # Git email comes from SOPS, not the personal default.
  my.user.email.git = "";

  # SOPS — work secrets (email, GitLab host, API keys, tokens)
  # NOTE: add work laptop age key to .sops.yaml before first deploy on work machine
  sops = {
    age.keyFile = "/Users/${username}/Library/Application Support/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/work-secrets.yaml;

    secrets = {
      work_email = { };
      gitlab_host = { };
      litellm_gateway_key = { };
      langfuse_public_key = { };
      langfuse_secret_key = { };
      aws_bedrock_role_arn = { };
    };
  };

  # Git includes gitconfig.local for identity + self-hosted instance URL shortcuts
  programs.git.includes = [
    { path = "${config.home.homeDirectory}/.gitconfig.local"; }
  ];

  # Activation: write ~/.gitconfig.local from decrypted SOPS secrets
  # Keeps work email and GitLab host URL out of the git repo entirely
  home.activation.gitLocalConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    email=$(cat "${config.sops.secrets.work_email.path}" 2>/dev/null || echo "")
    host=$(cat "${config.sops.secrets.gitlab_host.path}" 2>/dev/null || echo "")
    if [ -n "$email" ] || [ -n "$host" ]; then
      {
        if [ -n "$email" ]; then
          printf '[user]\n  email = %s\n' "$email"
        fi
        if [ -n "$host" ]; then
          printf '[url "https://%s/"]\n  insteadOf = enx:\n' "$host"
          printf '[url "git@%s:"]\n  insteadOf = enxs:\n' "$host"
        fi
      } > "${config.home.homeDirectory}/.gitconfig.local"
    fi
  '';

  # Export the SOPS-managed credential to a shared, client-neutral location.
  home.activation.aiGatewayEnv = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    gateway_env="${config.home.homeDirectory}/.config/enexis-ai-gateway/env"
    old_gateway_env="${config.home.homeDirectory}/.config/opencode/.env"
    gateway_key=$(cat "${config.sops.secrets.litellm_gateway_key.path}" 2>/dev/null || echo "")
    case "$gateway_key" in
      sk-*)
      umask 077
      mkdir -p "$(dirname "$gateway_env")"
      {
        printf 'ENEXIS_AI_GATEWAY_URL=https://api.ai.enexis.nl/v1\n'
        printf 'ENEXIS_AI_GATEWAY_KEY=%s\n' "$gateway_key"
      } > "$gateway_env"
      chmod 600 "$gateway_env"
      rm -f "$old_gateway_env"
      ;;
      *)
        rm -f "$gateway_env"
        echo "aiGatewayEnv: refusing to export an invalid LiteLLM key; replace litellm_gateway_key with a value starting with sk-" >&2
        ;;
    esac
  '';

  # TODO: glab config activation — disabled due to upstream home-manager compatibility
  # Re-enable after programs.glab.settings is supported in target home-manager version
  #
  # home.activation.glabHostConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   host=$(cat "${config.sops.secrets.gitlab_host.path}" 2>/dev/null || echo "")
  #   if [ -n "$host" ]; then
  #     glab_config="${config.home.homeDirectory}/.config/glab-cli/config.yml"
  #     mkdir -p "$(dirname "$glab_config")"
  #     if ! grep -q "$host" "$glab_config" 2>/dev/null; then
  #       cat >> "$glab_config" << EOF
  # hosts:
  #   $host:
  #     token: ""
  #     git_protocol: ssh
  #     api_protocol: https
  # EOF
  #     fi
  #   fi
  # '';

  # Activation: deploy dotfiles via chezmoi pointing to local nix repo source
  # Dotfiles live in hosts/work/dotfiles/ — versioned together with this nix config
  # On every run: initializes/applies chezmoi from the local source (with --force so
  # pre-existing handwritten dotfiles get overwritten by the repo-managed versions).
  # To update dotfiles: edit files in hosts/work/dotfiles/, then run 'chezmoi apply'
  # (or rebuild — this activation will re-apply on every home-manager switch).
  home.activation.chezmoiInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dotfiles_source="${./dotfiles}"
    # The selected Nix flake revision is the source of truth. This avoids
    # silently using a stale checkout at ~/.config/nix.
    ${pkgs.chezmoi}/bin/chezmoi --source "$dotfiles_source" apply --force
  '';

  # Work-specific packages (beyond features)
  home.packages = with pkgs; [
    # Shell (chezmoi-managed config — see programs.zsh.enable override above)
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship
    atuin

    # Shell history layering (zshrc has conditional integrations for all three)
    mcfly
    hstr
    pay-respects

    # Media / general utility
    ffmpeg
    imagemagick
    moonlight-qt
    mosh

    # AWS SSM — installed via Homebrew (see hosts/work/darwin.nix)

    # Dotfiles management
    chezmoi
    duti
  ];

  # Work environment variables are exported via chezmoi-managed ~/.zshrc
  # (see hosts/work/dotfiles/home/dot_zshrc.tmpl — WORK_ENV, NIX_HOST, AWS_*).
  # Host name and username are interpolated by chezmoi templates from ~/.config/chezmoi.
}
