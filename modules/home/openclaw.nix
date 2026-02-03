{ config, pkgs, lib, inputs, ... }:

{
  # Import the OpenClaw Home Manager module
  imports = [
    inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  # OpenClaw configuration
  programs.openclaw = {
    enable = true;
    
    # Use package from nix-openclaw flake (override default)
    package = inputs.nix-openclaw.packages.${pkgs.system}.openclaw;
    
    # Documents directory with AGENTS.md, SOUL.md, TOOLS.md, etc.
    documents = ./documents;
    
    # NOTE: Extra configuratie (modellen, providers, channels) kan via:
    # - ~/.openclaw/openclaw.json (manuele config)
    # - Environment variables (OLLAMA_HOST, etc.)
    # - De nix-openclaw module opties (zie documentatie)
    
    # Instance configuration
    instances.default = {
      enable = true;
      package = inputs.nix-openclaw.packages.${pkgs.system}.openclaw;
      stateDir = "${config.home.homeDirectory}/.openclaw";
      workspaceDir = "${config.home.homeDirectory}/.openclaw/workspace";
      launchd.enable = false;  # Disabled - using custom launchd agent below to control KeepAlive behavior

      # Gateway configuration
      # LET OP: De auth token wordt via environment variable gezet (niet hier!)
      # Zie de launchd agent EnvironmentVariables hieronder
      config = {
        gateway = {
          mode = "local";
          # Auth config wordt runtime ingelezen uit secret file
        };
      };

      # First-party plugins (tools + skills)
      # NOTE: Plugins temporarily disabled - need to add as flake inputs first
      # For now, OpenClaw works with built-in tools only
      plugins = [
        # Plugins will be added here once configured as flake inputs
        # See: github:openclaw/nix-steipete-tools for available tools
      ];
    };
    
    # Exclude tools you already have installed elsewhere
    # excludeTools = [ "git" "jq" "ripgrep" ];
  };
  
  # Ensure secrets directory exists (for later use)
  home.file.".secrets/.keep".text = "";

  # Helper script to stop OpenClaw gateway (launchctl stop doesn't work reliably)
  home.file.".local/bin/openclaw-stop" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Stop OpenClaw gateway (workaround: launchctl stop doesn't work)
      PID=$(pgrep openclaw-gateway)
      if [ -n "$PID" ]; then
        echo "Stopping OpenClaw gateway (PID: $PID)..."
        kill -TERM "$PID"
        sleep 1
        if pgrep openclaw-gateway > /dev/null; then
          echo "Force killing..."
          kill -9 "$PID"
        fi
        echo "Gateway stopped"
      else
        echo "OpenClaw gateway is not running"
      fi
    '';
  };
  
  # Ollama environment variables for local LLM
  home.sessionVariables = {
    OLLAMA_HOST = "127.0.0.1:11434";
    # Optional: Keep models in a specific directory
    # OLLAMA_MODELS = "${config.home.homeDirectory}/.ollama/models";
  };

  # Ensure Ollama service is running (if using Nix to manage it)
  # Note: You already have Ollama installed via Homebrew, so this is optional
  # Uncomment below if you want Nix to manage Ollama instead:
  # services.ollama.enable = true;
  # services.ollama.host = "127.0.0.1";
  # services.ollama.port = 11434;

  # Custom launchd agent with KeepAlive disabled (manual control)
  launchd.agents."com.steipete.openclaw.gateway" = {
    enable = true;
    config = {
      Label = "com.steipete.openclaw.gateway";
      ProgramArguments = [
        "${inputs.nix-openclaw.packages.${pkgs.system}.openclaw}/bin/openclaw"
        "gateway"
        "--port"
        "18789"
      ];
      RunAtLoad = true;
      KeepAlive = false;  # Disable auto-restart - you control start/stop manually
      WorkingDirectory = "${config.home.homeDirectory}/.openclaw";
      StandardOutPath = "/tmp/openclaw/openclaw-gateway.log";
      StandardErrorPath = "/tmp/openclaw/openclaw-gateway.log";
      EnvironmentVariables = {
        HOME = config.home.homeDirectory;
        OPENCLAW_CONFIG_PATH = "${config.home.homeDirectory}/.openclaw/openclaw.json";
        OPENCLAW_STATE_DIR = "${config.home.homeDirectory}/.openclaw";
        OPENCLAW_NIX_MODE = "1";
        # Gateway token uit sops-nix secrets (runtime decrypt)
        OPENCLAW_GATEWAY_TOKEN_FILE = config.sops.secrets.openclaw_api_key.path;
        MOLTBOT_CONFIG_PATH = "${config.home.homeDirectory}/.openclaw/openclaw.json";
        MOLTBOT_STATE_DIR = "${config.home.homeDirectory}/.openclaw";
        MOLTBOT_NIX_MODE = "1";
        CLAWDBOT_CONFIG_PATH = "${config.home.homeDirectory}/.openclaw/openclaw.json";
        CLAWDBOT_STATE_DIR = "${config.home.homeDirectory}/.openclaw";
        CLAWDBOT_NIX_MODE = "1";
      };
    };
  };
}
