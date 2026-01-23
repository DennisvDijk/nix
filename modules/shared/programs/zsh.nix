{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    history = {
      size = 10000;
      share = true;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
    };

    setOptions = [ "AUTOCD" "CORRECT" ];

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "fzf" "vi-mode" ];
    };

    shellAliases = {
      ll = "ls -lah";
    };

    # Common shell initialization
    initContent = ''
      export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=up:3:hidden:wrap --bind 'ctrl-p:toggle-preview,ctrl-k:up,ctrl-j:down'"
       
      # Starship prompt
      eval "$(starship init zsh)"
       
      # Smart rebuild functions
      function nix-rebuild() {
        local host=''${NIX_HOST:-personal}
        echo "🔨 Rebuilding darwin system for host: $host"
        sudo darwin-rebuild switch --flake ~/.config/nix#$host
      }
       
      function home-rebuild() {
        local host=''${NIX_HOST:-personal}
        echo "🏠 Rebuilding home-manager for host: $host"
        home-manager switch --flake ~/.config/nix#$host
      }
       
      function nix-full-rebuild() {
        local host=''${NIX_HOST:-personal}
        echo "🚀 Full rebuild for host: $host"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1️⃣  Darwin system..."
        sudo darwin-rebuild switch --flake ~/.config/nix#$host && \
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && \
        echo "2️⃣  Home Manager..." && \
        home-manager switch --flake ~/.config/nix#$host && \
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && \
        echo "✅ Rebuild complete!"
      }
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}