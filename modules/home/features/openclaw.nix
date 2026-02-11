# modules/home/features/openclaw.nix
# OpenClaw AI assistant Docker setup

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.features.openclaw;
  openclawDir = "${config.home.homeDirectory}/.config/openclaw";
in
{
  options.my.features.openclaw = {
    enable = mkEnableOption "OpenClaw AI assistant with Docker" // { default = false; };
    
    buildImage = mkEnableOption "Build OpenClaw Docker image on activation" // { default = false; };
    
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/nix/hosts/personal/openclaw";
      description = "Path to OpenClaw configuration files";
    };
  };

  config = mkIf cfg.enable {
    # OpenClaw packages
    home.packages = with pkgs; [
      docker
      docker-compose
      sops
      age
    ];

    # OpenClaw configuration files
    home.file = {
      ".config/openclaw/docker-compose.yml".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/docker-compose.yml";
      
      ".config/openclaw/.env.example".source = 
        config.lib.file.mkOutOfStoreSymlink "${cfg.configDir}/.env.example";
      
      ".secrets/.keep".text = "";
      
      ".openclaw/openclaw.json" = {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink 
          "${cfg.configDir}/openclaw.json";
      };
    };
    
    # OpenClaw activation scripts
    home.activation.linkOpenclawDocuments = lib.hm.dag.entryAfter ["writeBoundary"] ''
      DOC_DIR="${cfg.configDir}/documents"
      WORKSPACE_DIR="${config.home.homeDirectory}/.openclaw/workspace"
      
      mkdir -p "$WORKSPACE_DIR"
      rm -rf "$WORKSPACE_DIR"/*
      
      if [ -d "$DOC_DIR" ]; then
        for doc in "$DOC_DIR"/*.md; do
          if [ -f "$doc" ]; then
            ln -sf "$doc" "$WORKSPACE_DIR/"
          fi
        done
        echo "OpenClaw documents symlinked"
      fi
    '';
    
    home.activation.setupOpenclaw = lib.hm.dag.entryAfter ["linkOpenclawDocuments"] ''
      export PATH="${pkgs.docker}/bin:$PATH"
      
      OPENCLAW_DIR="${openclawDir}"
      OPENCLAW_SRC="${config.home.homeDirectory}/.local/share/openclaw-src"
      
      # Docker image management (only if buildImage is enabled)
      if command -v docker >/dev/null 2>&1; then
        if [ "''${OPENCLAW_BUILD_IMAGE:-}" = "1" ] || [ "''${OPENCLAW_BUILD_IMAGE:-}" = "true" ]; then
          echo "OPENCLAW_BUILD_IMAGE is set - rebuilding OpenClaw Docker image..."
          
          if [ ! -d "$OPENCLAW_SRC" ]; then
            echo "Cloning OpenClaw repository..."
            ${pkgs.git}/bin/git clone https://github.com/openclaw/openclaw.git "$OPENCLAW_SRC"
          else
            echo "Updating existing OpenClaw repository..."
            cd "$OPENCLAW_SRC" && ${pkgs.git}/bin/git pull origin main
          fi
          
          cd "$OPENCLAW_SRC"
          docker build -t openclaw:local -f "$OPENCLAW_SRC/Dockerfile" "$OPENCLAW_SRC"
          echo "OpenClaw Docker image built successfully"
        fi
      fi
      
      # Create .env file with SOPS secrets
      TOKEN_FILE="${config.sops.secrets.openclaw_api_key.path}"
      if [ -f "$TOKEN_FILE" ]; then
        TOKEN=$(cat "$TOKEN_FILE")
        
        cat > "$OPENCLAW_DIR/.env" << EOF
OPENCLAW_VERSION=latest
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_BIND=0.0.0.0
OPENCLAW_CONFIG_DIR=${config.home.homeDirectory}/.openclaw
OPENCLAW_WORKSPACE_DIR=${config.home.homeDirectory}/.openclaw/workspace
OPENCLAW_GATEWAY_TOKEN=$TOKEN
EOF
        chmod 600 "$OPENCLAW_DIR/.env"
        echo "OpenClaw environment configured"
      fi
    '';
    
    # Zsh aliases for OpenClaw
    programs.zsh.initContent = lib.mkAfter ''
      export OPENCLAW_DIR="${openclawDir}"
      
      # OpenClaw Docker aliases - Gateway management
      alias oc-up="cd $OPENCLAW_DIR && docker compose up -d"
      alias oc-down="cd $OPENCLAW_DIR && docker compose down"
      alias oc-logs="cd $OPENCLAW_DIR && docker compose logs -f openclaw-gateway"
      alias oc-ps="cd $OPENCLAW_DIR && docker compose ps"
      alias oc-shell="cd $OPENCLAW_DIR && docker compose exec openclaw-gateway /bin/sh"
      alias oc-health='curl -s http://localhost:18789/health | jq'
      
      # OpenClaw CLI aliases
      alias oc="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli"
      alias oc-onboard="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli onboard"
      alias oc-channels="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli channels"
      alias oc-agents="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli agents"
      alias oc-tools="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli tools"
      alias oc-status="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli status"
      
      # Image rebuild alias
      alias oc-rebuild="echo 'Run: OPENCLAW_BUILD_IMAGE=1 home-manager switch --flake .#personal'"
      
      export OPENCLAW_ENABLED=1
    '';
  };
}
