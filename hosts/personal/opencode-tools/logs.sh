#!/usr/bin/env bash
# OpenCode DevTools - Logs Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SERVICE="${1:-}"
FOLLOW="${2:-}"

if [ -n "$FOLLOW" ] && [ "$FOLLOW" = "-f" ]; then
    FOLLOW_FLAG="-f"
fi

if [ -n "$SERVICE" ]; then
    case "$SERVICE" in
        searxng)
            echo -e "${GREEN}Following SearXNG logs...${NC}"
            docker compose logs -f searxng
            ;;
        ollama)
            echo -e "${GREEN}Following Ollama logs...${NC}"
            docker compose logs -f ollama
            ;;
        litellm)
            echo -e "${GREEN}Following LiteLLM logs...${NC}"
            docker compose logs -f litellm
            ;;
        openwebui|webui)
            echo -e "${GREEN}Following Open WebUI logs...${NC}"
            docker compose logs -f open-webui
            ;;
        n8n)
            echo -e "${GREEN}Following n8n logs...${NC}"
            docker compose logs -f n8n
            ;;
        qdrant)
            echo -e "${GREEN}Following Qdrant logs...${NC}"
            docker compose logs -f qdrant
            ;;
        postgres|db)
            echo -e "${GREEN}Following PostgreSQL logs...${NC}"
            docker compose logs -f postgres
            ;;
        valkey|redis)
            echo -e "${GREEN}Following Valkey logs...${NC}"
            docker compose logs -f valkey
            ;;
        all)
            echo -e "${GREEN}Following all logs...${NC}"
            docker compose logs -f
            ;;
        *)
            echo -e "${GREEN}Following logs for: $SERVICE${NC}"
            docker compose logs -f $SERVICE
            ;;
    esac
else
    echo -e "${YELLOW}Usage: $0 <service> [-f]"
    echo ""
    echo "Services:"
    echo "  searxng     - SearXNG search"
    echo "  ollama      - Ollama LLM"
    echo "  litellm     - LiteLLM gateway"
    echo "  openwebui   - Open WebUI"
    echo "  n8n         - n8n workflow"
    echo "  qdrant      - Qdrant vector DB"
    echo "  postgres    - PostgreSQL"
    echo "  valkey      - Valkey cache"
    echo "  all         - All services"
    echo ""
    echo "Options:"
    echo "  -f          - Follow logs (tail -f)"
    exit 1
fi
