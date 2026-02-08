# hosts/personal/home.nix
# Personal host home configuration using feature flags

{ config, pkgs, lib, inputs, ... }:

let
  openclawDir = "${config.home.homeDirectory}/.config/openclaw";
in
{
  imports = [
    ../../modules/home/features  # Import all feature modules
  ];

  # Host-specific identity
  home.username = "dennisvandijk";
  home.homeDirectory = "/Users/dennisvandijk";
  home.stateVersion = "25.05";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Feature flags configuration
  my.features = {
    # Core (enabled by default)
    shell = {
      enable = true;
      starship.enable = true;
      direnv.enable = true;
      zoxide.enable = true;
      atuin.enable = true;
    };
    
    cli.enable = true;
    
    git = {
      enable = true;
      userName = "Dennis van Dijk";
      userEmail = "dennis@thenextgen.nl";
      delta.enable = true;
      lazygit.enable = true;
      jujutsu.enable = true;
      githubCli.enable = true;
    };
    
    terminal = {
      enable = true;
      wezterm.enable = true;
      alacritty.enable = true;
      kitty.enable = false;
      iterm2.enable = true;
    };
    
    # nh configuration
    nh = {
      enable = true;
      flakeDir = "${config.home.homeDirectory}/.config/nix";
      defaultDarwinHost = "personal";
    };
    
    # Personal-specific features
    dev = {
      enable = true;
      docker.enable = true;
      node.enable = true;
      python.enable = true;
      http.enable = true;
    };
    
    k8s = {
      enable = true;
      kubectl.enable = true;
      k9s.enable = true;
      helm.enable = false;  # Not needed for personal
      operators.enable = false;
      cloud.enable = false;
    };
    
    ai = {
      enable = true;
      codingAssistants.enable = true;
      llmTools.enable = true;
      localLLMs.enable = true;
    };
  };

  # User identity configuration (stored in secrets/user.yaml)
  # These are personal identifiers, not sensitive secrets
  my.user = {
    fullName = "Dennis van Dijk";
    firstName = "Dennis";
    lastName = "van Dijk";
    email.personal = "dennis@thenextgen.nl";
    email.git = "dennis@thenextgen.nl";
    email.work = "";
    username = "dennisvandijk";
    homeDirectory = "/Users/dennisvandijk";
  };

  # SOPS configuration for secret management (API keys, tokens, passwords)
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
  };

  # LM Studio configuration
  home.sessionPath = [
    "${config.home.homeDirectory}/.lmstudio/bin"
  ];

  home.file.".config/lm-studio/config.json".text = lib.mkForce ''
    {
      "bootstrappedByHomeManager": true
    }
  '';

  # Personal-specific packages (things not covered by features)
  home.packages = with pkgs; [
    # Media tools (personal-specific)
    ffmpeg
    imagemagick
    
    # Secrets management
    sops
    age
  ];

  # OpenClaw Docker Compose setup
  home.file = {
    ".config/openclaw/docker-compose.yml".source = ./openclaw/docker-compose.yml;
    ".config/openclaw/.env.example".source = ./openclaw/.env.example;
    ".secrets/.keep".text = "";
    
    ".openclaw/openclaw.json" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink 
        "${config.home.homeDirectory}/.config/nix/hosts/personal/openclaw/openclaw.json";
    };
  };
  
  # OpenClaw activation scripts
  home.activation.linkOpenclawDocuments = lib.hm.dag.entryAfter ["writeBoundary"] ''
    DOC_DIR="${config.home.homeDirectory}/.config/nix/hosts/personal/openclaw/documents"
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
    
    # Docker image management
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
    
    alias oc-up="cd $OPENCLAW_DIR && docker compose up -d"
    alias oc-down="cd $OPENCLAW_DIR && docker compose down"
    alias oc-logs="cd $OPENCLAW_DIR && docker compose logs -f openclaw-gateway"
    alias oc-ps="cd $OPENCLAW_DIR && docker compose ps"
    alias oc-shell="cd $OPENCLAW_DIR && docker compose exec openclaw-gateway /bin/sh"
    alias oc-health='curl -s http://localhost:18789/health | jq'
    alias oc="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli"
    alias oc-onboard="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli onboard"
    alias oc-channels="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli channels"
    alias oc-agents="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli agents"
    alias oc-tools="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli tools"
    alias oc-status="cd $OPENCLAW_DIR && docker compose run --rm openclaw-cli status"
    alias oc-rebuild="echo 'Run: OPENCLAW_BUILD_IMAGE=1 home-manager switch --flake .#personal'"
    
    export PERSONAL_ENV=1
    export NIX_HOST="personal"
  '';
}
