{ config, pkgs, lib, inputs, ... }:

let
  openclawDir = "${config.home.homeDirectory}/.config/openclaw";
in
{
  imports = [
    ../../modules/shared/home-manager.nix
  ];

  # SOPS configuration for secret management
  sops = {
    age.keyFile = "/Users/dennisvandijk/Library/Application Support/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/example.yaml;
    
    secrets = {
      openclaw_api_key = {
        sopsFile = ../../secrets/openclaw.yaml;
        key = "openclaw_api_key";
      };
      telegram_bot_name = {
        sopsFile = ../../secrets/openclaw.yaml;
        key = "telegram_bot_name";
      };
      telegram_bot_token = {
        sopsFile = ../../secrets/openclaw.yaml;
        key = "telegram_bot_token";
      };
      telegram_chat_id = {
        sopsFile = ../../secrets/openclaw.yaml;
        key = "telegram_chat_id";
      };
    };
    
    # Optional secrets - uncomment after adding to secrets/openclaw.yaml
    # gemini_api_key = {
    #   sopsFile = ../../secrets/openclaw.yaml;
    #   key = "gemini_api_key";
    # };
  };

  # Personal-specific packages
  home.packages = with pkgs; [
    ffmpeg
    imagemagick
    docker
    docker-compose
    sops
    age
  ];

  # OpenClaw Docker Compose setup
  home.file = {
    # Docker compose file
    ".config/openclaw/docker-compose.yml".source = ./openclaw/docker-compose.yml;
    
    # Environment file template
    ".config/openclaw/.env.example".source = ./openclaw/.env.example;
    
    # OpenClaw config
    ".openclaw/openclaw.json" = {
      force = true;
      text = builtins.readFile ./openclaw/openclaw.json;
    };
    
    # Secrets placeholder
    ".secrets/.keep".text = "";
  };

  # Copy documents, build image, and setup secrets
  home.activation.setupOpenclaw = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.docker}/bin:$PATH"
    
    OPENCLAW_DIR="${openclawDir}"
    WORKSPACE_DIR="${config.home.homeDirectory}/.openclaw/workspace"
    DOC_DIR="${config.home.homeDirectory}/.config/nix/hosts/personal/openclaw/documents"
    OPENCLAW_SRC="${config.home.homeDirectory}/.local/share/openclaw-src"
    
    mkdir -p "$WORKSPACE_DIR"
    
    # Copy documents
    if [ -d "$DOC_DIR" ]; then
      cp -f "$DOC_DIR/"*.md "$WORKSPACE_DIR/" 2>/dev/null || true
      echo "OpenClaw documents synced"
    fi
    
    # Clone and build OpenClaw Docker image (controlled by OPENCLAW_BUILD_IMAGE env var)
    if command -v docker >/dev/null 2>&1; then
      if [ "''${OPENCLAW_BUILD_IMAGE:-}" = "1" ] || [ "''${OPENCLAW_BUILD_IMAGE:-}" = "true" ]; then
        echo "OPENCLAW_BUILD_IMAGE is set - rebuilding OpenClaw Docker image..."
        
        # Clone repository if not exists, otherwise update
        if [ ! -d "$OPENCLAW_SRC" ]; then
          echo "Cloning OpenClaw repository..."
          ${pkgs.git}/bin/git clone https://github.com/openclaw/openclaw.git "$OPENCLAW_SRC"
        else
          echo "Updating existing OpenClaw repository..."
          cd "$OPENCLAW_SRC" && ${pkgs.git}/bin/git pull origin main
        fi
        
        # Build Docker image
        cd "$OPENCLAW_SRC"
        docker build -t openclaw:local -f "$OPENCLAW_SRC/Dockerfile" "$OPENCLAW_SRC"
        echo "OpenClaw Docker image built successfully"
      elif ! docker image inspect openclaw:local >/dev/null 2>&1; then
        echo "OpenClaw Docker image not found. To build it, run:"
        echo "  OPENCLAW_BUILD_IMAGE=1 home-manager switch --flake .#personal"
        echo ""
        echo "Or build manually:"
        echo "  git clone https://github.com/openclaw/openclaw.git ~/.local/share/openclaw-src"
        echo "  cd ~/.local/share/openclaw-src && docker build -t openclaw:local ."
      else
        echo "OpenClaw Docker image exists (set OPENCLAW_BUILD_IMAGE=1 to rebuild)"
      fi
    else
      echo "Note: Docker not available in activation, skipping image build"
    fi
    
    # Create .env file with token from sops
    TOKEN_FILE="${config.sops.secrets.openclaw_api_key.path}"
    if [ -f "$TOKEN_FILE" ]; then
      TOKEN=$(cat "$TOKEN_FILE")
      cat > "$OPENCLAW_DIR/.env" << EOF
OPENCLAW_VERSION=latest
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_BIND=loopback
OPENCLAW_CONFIG_DIR=${config.home.homeDirectory}/.openclaw
OPENCLAW_WORKSPACE_DIR=${config.home.homeDirectory}/.openclaw/workspace
OPENCLAW_GATEWAY_TOKEN=$TOKEN
EOF
      chmod 600 "$OPENCLAW_DIR/.env"
      echo "OpenClaw environment configured"
    else
      echo "Warning: OpenClaw API key not found, .env not created"
    fi
    
    # Setup optional secrets (manual step after adding to secrets/openclaw.yaml)
    # To enable Gemini and Telegram, add these keys to secrets/openclaw.yaml:
    #   gemini_api_key: your-key-here
    #   telegram_bot_token: your-token-here
    # Then uncomment the secrets above and rebuild
  '';

  # Zsh aliases for Docker-based OpenClaw
  programs.zsh.initContent = lib.mkAfter ''
    export OPENCLAW_DIR="${openclawDir}"
    
    # OpenClaw Docker aliases - Gateway management
    alias oc-up="cd $OPENCLAW_DIR && docker compose up -d"
    alias oc-down="cd $OPENCLAW_DIR && docker compose down"
    alias oc-logs="cd $OPENCLAW_DIR && docker compose logs -f openclaw-gateway"
    alias oc-ps="cd $OPENCLAW_DIR && docker compose ps"
    alias oc-shell="cd $OPENCLAW_DIR && docker compose exec openclaw-gateway /bin/sh"
    alias oc-health='curl -s http://localhost:18789/health | jq'
    
    # OpenClaw CLI aliases - Use these for openclaw commands
    alias oc="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli"
    alias oc-onboard="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli onboard"
    alias oc-channels="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli channels"
    alias oc-agents="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli agents"
    alias oc-tools="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli tools"
    alias oc-status="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli status"
    
    # Image rebuild alias
    alias oc-rebuild="echo 'Run: OPENCLAW_BUILD_IMAGE=1 home-manager switch --flake .#personal'"
    
    export PERSONAL_ENV=1
    export NIX_HOST="personal"
  '';
}
