# hosts/personal/home.nix
# Personal host home configuration using feature flags

{ config, pkgs, lib, inputs, username, hostName, ... }:

{
  imports = [
    ../../modules/shared/home-manager.nix  # Base config (core packages)
    ../../modules/home/features             # Feature system
  ];

  # Host identification (provided by flake via specialArgs)
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Nix binary cache for faster builds
  nix.settings.substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
  nix.settings.trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];

  # Feature flags configuration - personal has everything enabled
  my.features = {
    # Core (enabled by default via features/default.nix)
    shell = {
      enable = true;
      # chezmoi owns ~/.zshrc — disable HM file generation and zsh integrations
      starship.enable = false;
      direnv.enable = true;
      zoxide.enable = true;
      atuin.enable = false;
    };
    
    cli.enable = true;
    
    git = {
      enable = true;
      userName = "Dennis van Dijk";
      userEmail = "dennis@thenextgen.nl";
      delta.enable = true;
      lazygit.enable = true;
      jujutsu.enable = true;
      githubCli.enable = true;
      gitlabCli.enable = false;
    };
    
    terminal = {
      enable = true;
      wezterm.enable = true;
      alacritty.enable = true;
      kitty.enable = false;
      iterm2.enable = true;
    };
    
    # nh configuration
    nh = {
      enable = true;
      flakeDir = "${config.home.homeDirectory}/.config/nix";
      defaultDarwinHost = "personal";
    };
    
    # Personal-specific features
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
      helm.enable = false;  # Not needed for personal
      operators.enable = false;
      cloud.enable = false;
    };
    
    ai = {
      enable = true;
      codingAssistants.enable = true;
      llmTools.enable = true;
      localLLMs.enable = true;
    };
    
    # OpenCode DevTools - Self-hosted AI development tools
    devtools = {
      enable = true;
      configDir = "${config.home.homeDirectory}/.config/nix/hosts/personal/opencode-tools";
    };
  };

  # Let chezmoi manage ~/.zshrc (like work host)
  programs.zsh.enable = lib.mkForce false;

  # User identity configuration
  # These are personal identifiers, not sensitive secrets
  my.user = {
    fullName = "Dennis van Dijk";
    firstName = "Dennis";
    lastName = "van Dijk";
    email.personal = "dennis@thenextgen.nl";
    email.git = "dennis@thenextgen.nl";
    email.work = "";
    username = username;
    homeDirectory = "/Users/${username}";
  };

  # SOPS configuration for secret management (API keys, tokens, passwords)
  sops = {
    age.keyFile = "/Users/dennisvandijk/Library/Application Support/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/example.yaml;
    
    secrets = { };
  };

  # Personal-specific packages (things not covered by features)
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

    # Media tools (personal-specific)
    ffmpeg
    imagemagick
    moonlight-qt
    mosh
  ];

  # Run chezmoi init/apply on every home-manager switch (chezmoi owns ~/.zshrc)
  home.activation.chezmoiInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dotfiles_source="${config.home.homeDirectory}/.config/nix/hosts/personal/dotfiles"
    chezmoi_dir="${config.home.homeDirectory}/.local/share/chezmoi"
    if [ -d "$dotfiles_source" ]; then
      if [ ! -d "$chezmoi_dir" ]; then
        echo "chezmoi: initialising from local nix repo source..."
        ${pkgs.chezmoi}/bin/chezmoi init --source "$dotfiles_source" --apply --force
      else
        ${pkgs.chezmoi}/bin/chezmoi apply --source "$dotfiles_source" --force
      fi
    fi
  '';
}
