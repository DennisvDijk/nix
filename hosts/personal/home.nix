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
      gemini_api_key = {
        sopsFile = ../../secrets/openclaw.yaml;
        key = "gemini_api_key";
      };
    };
  };

  # Personal-specific packages
  home.packages = with pkgs; [
    ffmpeg
    imagemagick
    docker
    docker-compose
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

  # Copy documents and setup secrets
  home.activation.setupOpenclaw = lib.hm.dag.entryAfter ["writeBoundary"] ''
    OPENCLAW_DIR="${openclawDir}"
    WORKSPACE_DIR="${config.home.homeDirectory}/.openclaw/workspace"
    DOC_DIR="${config.home.homeDirectory}/.config/nix/hosts/personal/openclaw/documents"
    
    mkdir -p "$WORKSPACE_DIR"
    
    # Copy documents
    if [ -d "$DOC_DIR" ]; then
      cp -f "$DOC_DIR/"*.md "$WORKSPACE_DIR/" 2>/dev/null || true
      echo "OpenClaw documents synced"
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
    
    # Setup Gemini API key
    GEMINI_KEY_FILE="${config.sops.secrets.gemini_api_key.path}"
    if [ -f "$GEMINI_KEY_FILE" ]; then
      cp "$GEMINI_KEY_FILE" "${config.home.homeDirectory}/.openclaw/gemini-key"
      chmod 600 "${config.home.homeDirectory}/.openclaw/gemini-key"
      echo "Gemini API key configured"
    else
      echo "Warning: Gemini API key not found in secrets"
    fi
    
    # Setup Telegram bot token
    TELEGRAM_TOKEN_FILE="${config.sops.secrets.telegram_bot_token.path}"
    if [ -f "$TELEGRAM_TOKEN_FILE" ]; then
      cp "$TELEGRAM_TOKEN_FILE" "${config.home.homeDirectory}/.openclaw/telegram-token"
      chmod 600 "${config.home.homeDirectory}/.openclaw/telegram-token"
      echo "Telegram bot token configured"
    else
      echo "Warning: Telegram bot token not found in secrets"
    fi
  '';

  # Zsh aliases for Docker-based OpenClaw
  programs.zsh.initContent = lib.mkAfter ''
    export OPENCLAW_DIR="${openclawDir}"
    
    # OpenClaw Docker aliases - Gateway
    alias oc-up="cd $OPENCLAW_DIR && docker compose up -d"
    alias oc-down="cd $OPENCLAW_DIR && docker compose down"
    alias oc-logs="cd $OPENCLAW_DIR && docker compose logs -f openclaw-gateway"
    alias oc-ps="cd $OPENCLAW_DIR && docker compose ps"
    alias oc-exec="cd $OPENCLAW_DIR && docker compose exec openclaw-gateway"
    alias oc-health='curl -s http://localhost:18789/health | jq'
    
    # OpenClaw CLI aliases
    alias oc-cli="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli"
    alias oc-onboard="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli onboard"
    alias oc-channels="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli channels"
    alias oc-agents="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli agents"
    alias oc-tools="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli tools"
    
    export PERSONAL_ENV=1
    export NIX_HOST="personal"
  '';
}
