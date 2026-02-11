{ config, pkgs, lib, ... }:

{
  imports = [
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
  home.file.".config/opencode/opencode.json".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/nix/modules/config/opencode/opencode.json";

  # Aerospace window manager configuration
  home.file.".aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/nix/modules/config/aerospace.toml";

  # Sketchybar configuration files
  home.file.".config/sketchybar/sketchybarrc".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/nix/modules/config/sketchybar/sketchybarrc";
  
  home.file.".config/sketchybar/workspace_update.sh".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/nix/modules/config/sketchybar/workspace_update.sh";

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

    # AI-related tools - claude-code temporarily disabled due to npm registry connection issues
    # claude-code
    codex
    aider-chat
    gemini-cli

    # k8s
    kubectl
  ];
}