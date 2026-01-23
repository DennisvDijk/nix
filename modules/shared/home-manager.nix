{ config, pkgs, lib, ... }:

{
  imports = [
    ./services/sketchybar.nix
    ./programs/starship.nix
    ./programs/zsh.nix
    ./programs/chromium.nix
    ./ui/fonts.nix
    ./ui/terminal.nix
  ];

  home.username = "dennisvandijk";
  home.homeDirectory = "/Users/dennisvandijk";
  home.stateVersion = "25.05";

  home.sessionPath = [
    "${config.home.homeDirectory}/.lmstudio/bin"
  ];

  home.file.".config/lm-studio/config.json".text = lib.mkForce ''
  {
    "bootstrappedByHomeManager": true
  }
  '';

  # OpenCode configuration
  home.file.".config/opencode/opencode.json" = lib.homeManager.mkStoreOutOfSymlink {
    source = ../config/opencode/opencode.json;
  };

  # Aerospace window manager configuration
  home.file.".aerospace.toml" = lib.homeManager.mkStoreOutOfSymlink {
    source = ../config/aerospace.toml;
  };

  # Core packages
  home.packages = with pkgs; [
    # Productivity / UX
    atuin
    bat
    ripgrep
    fd
    eza
    fzf
    tealdeer
    jq
    yq-go
    neovim
    uv
    
    # Git & Dev
    gh
    delta
    glow
    httpie
    jujutsu
    nodejs

    # Networking & DevOps
    nmap
    iperf3
    kubectl
    docker-compose
    colima

    # Browser
    brave
    
    # File & Archive
    p7zip
    rsync
    rclone
    tree

    # System / macOS
    fastfetch
    mas
    m-cli
    reattach-to-user-namespace

    goose
    zsh-autosuggestions

    # AI-related tools
    claude-code
    codex
    aider-chat
    gemini-cli
  ];
}
