#!/usr/bin/env bash
# OpenCode DevTools - Restart Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  OpenCode DevTools - Restart${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

SERVICE="${1:-}"

if [ -n "$SERVICE" ]; then
    case "$SERVICE" in
        searxng)
            echo -e "${YELLOW}Restarting SearXNG...${NC}"
            docker compose restart searxng
            ;;
        ollama)
            echo -e "${YELLOW}Restarting Ollama...${NC}"
            docker compose restart ollama
            ;;
        litellm)
            echo -e "${YELLOW}Restarting LiteLLM...${NC}"
            docker compose restart litellm
            ;;
        openwebui|webui)
            echo -e "${YELLOW}Restarting Open WebUI...${NC}"
            docker compose restart open-webui
            ;;
        n8n)
            echo -e "${YELLOW}Restarting n8n...${NC}"
            docker compose restart n8n
            ;;
        qdrant)
            echo -e "${YELLOW}Restarting Qdrant...${NC}"
            docker compose restart qdrant
            ;;
        postgres|db)
            echo -e "${YELLOW}Restarting PostgreSQL...${NC}"
            docker compose restart postgres
            ;;
        valkey|redis)
            echo -e "${YELLOW}Restarting Valkey...${NC}"
            docker compose restart valkey
            ;;
        all)
            echo -e "${YELLOW}Restarting all services...${NC}"
            docker compose restart
            ;;
        *)
            echo -e "${YELLOW}Restarting: $SERVICE${NC}"
            docker compose restart $SERVICE
            ;;
    esac
else
    echo -e "${YELLOW}Restarting all services...${NC}"
    docker compose restart
fi

echo ""
echo -e "${GREEN}Services restarted.${NC}"
