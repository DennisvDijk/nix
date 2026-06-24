# modules/shared/services/headroom.nix
# Headroom proxy — context compression layer for AI agents
# Runs as a launchd user agent: starts on login, auto-restarts on crash.
# The proxy compresses tool outputs, logs, and conversation history before
# they reach the LLM. With --memory and --learn it also provides persistent
# cross-session memory and failure-pattern learning.
#
# Requires headroom-ai installed via:  uv tool install "headroom-ai[all]"
# Binary lives at ~/.local/bin/headroom (added to PATH by .zshrc)

{ config, pkgs, lib, username, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types optionalString;
  cfg = config.my.services.headroom;

  home = config.users.users.${username}.home or "/Users/${username}";
  headroomBin = "${home}/.local/bin/headroom";
  logFile = "/tmp/headroom-proxy.log";
in
{
  options.my.services.headroom = {
    enable = mkEnableOption "Headroom context compression proxy" // { default = false; };

    port = mkOption {
      type = types.int;
      default = 8787;
      description = "Port for headroom proxy";
    };

    memory = mkOption {
      type = types.bool;
      default = true;
      description = "Enable persistent cross-session memory (SQLite, project-scoped)";
    };

    learn = mkOption {
      type = types.bool;
      default = true;
      description = "Enable live traffic learning (error→recovery patterns → AGENTS.md)";
    };

    codeGraph = mkOption {
      type = types.bool;
      default = true;
      description = "Enable code graph intelligence (indexes working directory)";
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents.headroom = {
      serviceConfig = {
        Label = "ai.headroom.proxy";
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            # Source .env if it exists (API keys, gateway URLs)
            if [ -f "${home}/.config/opencode/.env" ]; then
              set -a
              . "${home}/.config/opencode/.env"
              set +a
            fi

            # If Enexis gateway URL is set, strip /v1 suffix and use as the OpenAI upstream
            # (headroom proxy adds /v1/chat/completions itself — double /v1 would 404)
            if [ -n "$ENEXIS_AI_GATEWAY_URL" ]; then
              export OPENAI_TARGET_API_URL="''${ENEXIS_AI_GATEWAY_URL%%/v1}"
            fi

            exec ${headroomBin} proxy \
              --port ${toString cfg.port} \
              ${optionalString cfg.memory "--memory"} \
              ${optionalString cfg.learn "--learn"} \
              ${optionalString cfg.codeGraph "--code-graph"}
          ''
        ];
        EnvironmentVariables = {
          HEADROOM_OUTPUT_SHAPER = "1";
          HEADROOM_CACHE_ALIGN = "1";
          HEADROOM_LOG_LEVEL = "warn";
          HOME = home;
          PATH = "${home}/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
        };
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = logFile;
        StandardErrorPath = logFile;
      };
    };
  };
}
