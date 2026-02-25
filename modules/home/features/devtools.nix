# modules/home/features/devtools.nix
# OpenCode DevTools - Self-hosted AI development tools

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.features.devtools;
  devtoolsDir = "${config.home.homeDirectory}/.config/opencode-tools";
in
{
  options.my.features.devtools = {
    enable = mkEnableOption "OpenCode DevTools with Docker" // { default = false; };
    
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/nix/hosts/personal/opencode-tools";
      description = "Path to OpenCode DevTools configuration files";
    };
  };

  config = mkIf cfg.enable {
    # DevTools packages
    home.packages = with pkgs; [
      docker
      docker-compose
      sops
      age
      just
    ];

    # DevTools configuration files
    home.file = {
      ".config/opencode-tools/docker-compose.yml".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/docker-compose.yml";
      
      ".config/opencode-tools/.env.example".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/.env.example";
      
      ".config/opencode-tools/start.sh".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/start.sh";
      
      ".config/opencode-tools/stop.sh".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/stop.sh";
      
      ".config/opencode-tools/restart.sh".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/restart.sh";
      
      ".config/opencode-tools/logs.sh".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/logs.sh";
      
      ".config/opencode-tools/Makefile".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/Makefile";
    };
    
    # Make scripts executable
    home.activation.makeScriptsExecutable = lib.hm.dag.entryAfter ["writeBoundary"] ''
      chmod +x "${devtoolsDir}/start.sh" 2>/dev/null || true
      chmod +x "${devtoolsDir}/stop.sh" 2>/dev/null || true
      chmod +x "${devtoolsDir}/restart.sh" 2>/dev/null || true
      chmod +x "${devtoolsDir}/logs.sh" 2>/dev/null || true
    '';
    
    # DevTools activation - create .env from template if not exists
    home.activation.setupDevtools = lib.hm.dag.entryAfter ["makeScriptsExecutable"] ''
      DEVTOOLS_DIR="${devtoolsDir}"
      
      # Create .env file from .env.example if not exists
      if [ ! -f "$DEVTOOLS_DIR/.env" ]; then
        echo "Creating .env from template..."
        if [ -f "$DEVTOOLS_DIR/.env.example" ]; then
          cp "$DEVTOOLS_DIR/.env.example" "$DEVTOOLS_DIR/.env"
          echo "Created .env file. Please edit it to add your API keys!"
        else
          echo "Warning: .env.example not found"
        fi
      else
        echo "DevTools .env already exists, skipping"
      fi
    '';
    
    # Zsh aliases for DevTools
    programs.zsh.initContent = lib.mkAfter ''
      export DEVTOOLS_DIR="${devtoolsDir}"
      
      # DevTools Docker aliases
      alias dt-up="cd $DEVTOOLS_DIR && docker compose up -d"
      alias dt-down="cd $DEVTOOLS_DIR && docker compose down"
      alias dt-restart="cd $DEVTOOLS_DIR && docker compose restart"
      alias dt-logs="cd $DEVTOOLS_DIR && docker compose logs -f"
      alias dt-ps="cd $DEVTOOLS_DIR && docker compose ps"
      alias dt-pull="cd $DEVTOOLS_DIR && docker compose pull"
      
      # Service-specific aliases
      alias dt-search="cd $DEVTOOLS_DIR && docker compose up -d searxng"
      alias dt-llm="cd $DEVTOOLS_DIR && docker compose up -d ollama litellm open-webui"
      alias dt-ai="cd $DEVTOOLS_DIR && docker compose --profile ai up -d"
      alias dt-workflow="cd $DEVTOOLS_DIR && docker compose up -d n8n"
      alias dt-vector="cd $DEVTOOLS_DIR && docker compose up -d qdrant"
      alias dt-db="cd $DEVTOOLS_DIR && docker compose up -d postgres"
      
      # Full stack
      alias dt-full="cd $DEVTOOLS_DIR && docker compose --profile full up -d"
      alias dt-light="cd $DEVTOOLS_DIR && docker compose up -d"
      
      # Status checks
      alias dt-status="echo '=== DevTools Status ===' && curl -s http://localhost:8080/health 2>/dev/null | jq -r '.version' && echo 'SearXNG: OK' || echo 'SearXNG: DOWN'"
      alias dt-ports="echo '=== DevTools Ports ===' && ss -tlnp | grep -E ':(8080|6379|11434|4000|3000|5678|6333|5432)'"
      
      # Make commands available
      alias dt-make="cd $DEVTOOLS_DIR && make"
      
      export DEVTOOLS_ENABLED=1
    '';
  };
}
