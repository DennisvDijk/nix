{ pkgs, ... }:

{
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
}
