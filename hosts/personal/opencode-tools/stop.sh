#!/usr/bin/env bash
# OpenCode DevTools - Stop Script

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
echo -e "${BLUE}  OpenCode DevTools - Stop${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Parse arguments
SERVICES="${1:-}"
VOLUMES="${2:-}"

if [ -n "$SERVICES" ]; then
    case "$SERVICES" in
        searxng)
            echo -e "${YELLOW}Stopping SearXNG...${NC}"
            docker compose stop searxng
            ;;
        ollama)
            echo -e "${YELLOW}Stopping Ollama...${NC}"
            docker compose stop ollama
            ;;
        litellm)
            echo -e "${YELLOW}Stopping LiteLLM...${NC}"
            docker compose stop litellm
            ;;
        openwebui|webui)
            echo -e "${YELLOW}Stopping Open WebUI...${NC}"
            docker compose stop open-webui
            ;;
        n8n)
            echo -e "${YELLOW}Stopping n8n...${NC}"
            docker compose stop n8n
            ;;
        qdrant)
            echo -e "${YELLOW}Stopping Qdrant...${NC}"
            docker compose stop qdrant
            ;;
        postgres|db)
            echo -e "${YELLOW}Stopping PostgreSQL...${NC}"
            docker compose stop postgres
            ;;
        valkey|redis)
            echo -e "${YELLOW}Stopping Valkey...${NC}"
            docker compose stop valkey
            ;;
        all)
            echo -e "${YELLOW}Stopping all services...${NC}"
            docker compose stop
            ;;
        *)
            echo -e "${YELLOW}Stopping specific services: $SERVICES${NC}"
            docker compose stop $SERVICES
            ;;
    esac
else
    echo -e "${YELLOW}Stopping all running services...${NC}"
    docker compose stop
fi

echo ""
echo -e "${GREEN}Services stopped.${NC}"

if [ "$VOLUMES" = "--volumes" ] || [ "$VOLUMES" = "-v" ]; then
    echo -e "${RED}WARNING: Removing volumes...${NC}"
    docker compose down -v
    echo -e "${RED}Volumes removed.${NC}"
fi
