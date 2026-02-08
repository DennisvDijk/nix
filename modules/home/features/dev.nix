# modules/home/features/dev.nix
# Development tools - containers, languages, build tools

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.my.features.dev;
in
{
  options.my.features.dev = {
    enable = mkEnableOption "development tools and environments";
    
    docker.enable = mkEnableOption "Docker/Colima container tools" // { default = true; };
    node.enable = mkEnableOption "Node.js and npm" // { default = true; };
    python.enable = mkEnableOption "Python tools (uv, poetry)" // { default = true; };
    http.enable = mkEnableOption "HTTP client tools" // { default = true; };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      (mkIf cfg.docker.enable (with pkgs; [
        # Container tools from Nix
        docker
        docker-compose
        colima              # macOS container runtime
        lazydocker          # TUI for Docker
        dive                # Docker image analyzer
        skopeo              # Container image operations
        
        # Alternative: Podman
        podman
        podman-compose
      ]))
      
      (mkIf cfg.node.enable (with pkgs; [
        # Node.js ecosystem
        nodejs
        # Note: corepack is included with nodejs since v16.13+
        # corepack - DO NOT include separately, causes conflicts
        
        # Alternative package managers (optional)
        # pnpm
        # yarn
        
        # Node tools
        nodePackages.npm-check-updates
      ]))
      
      (mkIf cfg.python.enable (with pkgs; [
        # Modern Python tooling (from Nix!)
        uv                  # Fast Python package installer
        ruff                # Fast Python linter
        pyright             # Python type checker
        # poetry            # If needed (uv is preferred now)
        
        # Python itself is often better managed per-project with uv
        # but having a system Python can be useful
        python3
      ]))
      
      (mkIf cfg.http.enable (with pkgs; [
        # HTTP clients
        httpie              # Better curl
        xh                  # Fast HTTPie alternative in Rust
        curl                # Always have curl
        wget
        
        # API testing
        bruno               # API client (open source alternative to Postman)
      ]))
      
      (with pkgs; [
        # General development
        gnumake
        cmake
        gcc
        
        # Code analysis
        tokei               # Count lines of code
        hyperfine           # Benchmarking
        
        # Documentation
        marksman            # Markdown LSP
      ])
    ];

    # Docker/Colima integration
    programs.zsh.initExtra = mkIf cfg.docker.enable ''
      # Colima auto-completion and aliases
      if command -v colima &>/dev/null; then
        eval "$(colima completion zsh)"
      fi
      
      # Docker aliases
      alias d='docker'
      alias dc='docker compose'
      alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
      alias dprune='docker system prune -af'
    '';
  };
}
