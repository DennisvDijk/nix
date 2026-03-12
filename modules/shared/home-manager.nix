{ config, pkgs, lib, username ? "dennisvandijk", homeDirectory ? "/Users/dennisvandijk", ... }:

{
    # Core Home Manager settings
  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };

  # Enable Home Manager
  programs.home-manager.enable = true;
  nix.package = pkgs.nix;

  # Session path for local bins
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.lmstudio/bin"
  ];

  # Universal core packages - available on ALL hosts
  home.packages = with pkgs; [
    # === Core CLI Tools ===
    bat                     # Cat with syntax highlighting
    ripgrep                 # Grep alternative
    fd                      # Find alternative
    eza                     # Ls alternative
    fzf                     # Fuzzy finder
    tealdeer                # TLDR client
    
    # === Data Processing ===
    jq                      # JSON processor
    yq-go                   # YAML processor
    
    # === Version Control ===
    gh                      # GitHub CLI
    delta                   # Git pager
    git                     # Git
    
    # === Editor ===
    neovim                  # Editor
    
    # === Development ===
    uv                      # Python package manager
    nodejs                  # Node.js
    
    # === System ===
    fastfetch               # System info display
    
    # === Shells ===
    zsh                     # Zsh shell
    zsh-autosuggestions     # Shell suggestions
    
    # === Network ===
    mosh                    # Mobile shell
    nmap                    # Network scanner
  ];

  # LM Studio config (optional - only needed if using local LLMs)
  home.file.".config/lm-studio/config.json".text = ''
    {
      "bootstrappedByHomeManager": true
    }
  '';
}
