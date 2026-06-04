# hosts/work/home.nix
# Work host home configuration — Enexis AI Platform

{ config, pkgs, lib, inputs, username, hostName, ... }:

{
  imports = [
    ../../modules/shared/home-manager.nix  # Base config (core packages)
    ../../modules/home/features             # Feature system
  ];

  # Host identification (provided by flake via specialArgs)
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.05";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Nix binary cache for faster builds
  nix.settings.substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
  nix.settings.trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];

  # Feature flags — full work stack for Enexis AI Platform (LiteLLM/EKS/ArgoCD/Bedrock)
  my.features = {
    shell = {
      enable = true;
      starship.enable = true;
      direnv.enable = true;
      zoxide.enable = true;
      atuin.enable = true;
    };

    cli.enable = true;

    git = {
      enable = true;
      userName = "Dennis van Dijk";
      userEmail = null;          # Loaded via SOPS → ~/.gitconfig.local (see activation below)
      delta.enable = true;
      lazygit.enable = true;
      jujutsu.enable = true;
      githubCli.enable = false;  # Work uses GitLab, not GitHub
      gitlabCli.enable = true;   # Enexis: enx.gitlab.schubergphilis.com
    };

    terminal = {
      enable = true;
      wezterm.enable = true;
      alacritty.enable = false;
      kitty.enable = false;
      iterm2.enable = true;
    };

    nh = {
      enable = true;
      flakeDir = "${config.home.homeDirectory}/.config/nix";
      defaultDarwinHost = "work";
    };

    dev = {
      enable = true;
      docker.enable = true;
      node.enable = true;
      python.enable = true;
      http.enable = true;
    };

    k8s = {
      enable = true;
      kubectl.enable = true;
      k9s.enable = true;
      helm.enable = true;         # Required for ArgoCD/Kargo deployments
      operators.enable = true;    # ArgoCD CLI, kustomize, fluxcd
      cloud.enable = true;        # awscli2, azure-cli, sops, age — via Nix (not brew!)
    };

    ai = {
      enable = true;
      codingAssistants.enable = true;
      llmTools.enable = true;
      localLLMs.enable = false;   # No local LLMs on work laptop (data residency + RAM)
    };

    devtools.enable = false;      # Self-hosted opencode-tools stack is personal-only
  };

  # User identity — email loaded via SOPS, not plaintext
  my.user = {
    fullName = "Dennis van Dijk";
    firstName = "Dennis";
    lastName = "van Dijk";
    email.personal = "dennis@thenextgen.nl";
    email.git = "";               # Set via SOPS → gitconfig.local activation
    email.work = "";              # Set via SOPS → gitconfig.local activation
    username = username;
    homeDirectory = "/Users/${username}";
  };

  # SOPS — work secrets (email, GitLab host, API keys, tokens)
  # NOTE: add work laptop age key to .sops.yaml before first deploy on work machine
  sops = {
    age.keyFile = "/Users/${username}/Library/Application Support/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/work-secrets.yaml;

    secrets = {
      work_email          = { };
      gitlab_host         = { };
      litellm_master_key  = { };
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
  # On first run: initialises chezmoi from the local source and applies
  # To update dotfiles: edit files in hosts/work/dotfiles/, then run 'chezmoi apply'
  home.activation.chezmoiInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dotfiles_source="${config.home.homeDirectory}/.config/nix/hosts/work/dotfiles"
    chezmoi_dir="${config.home.homeDirectory}/.local/share/chezmoi"
    if [ -d "$dotfiles_source" ]; then
      if [ ! -d "$chezmoi_dir" ]; then
        echo "chezmoi: initialising from local nix repo source..."
        ${pkgs.chezmoi}/bin/chezmoi init --source "$dotfiles_source" --apply
      else
        # Already initialised — apply any changes from the nix repo
        ${pkgs.chezmoi}/bin/chezmoi apply --source "$dotfiles_source"
      fi
    fi
  '';

  # Work-specific packages (beyond features)
  home.packages = with pkgs; [
    # Media / general utility
    ffmpeg
    imagemagick
    mosh

    # AWS SSM — not included in k8s.cloud feature
    session-manager-plugin

    # Dotfiles management
    chezmoi
  ];

  # Work environment variables
  programs.zsh.initContent = lib.mkAfter ''
    export WORK_ENV=1
    export NIX_HOST="${hostName}"
    export AWS_DEFAULT_REGION="eu-west-1"    # Data residency: EU only (Bedrock eu-west-1)
    export AWS_REGION="eu-west-1"
  '';
}
