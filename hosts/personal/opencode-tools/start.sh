#!/usr/bin/env bash
# OpenCode DevTools - Startup Script

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
echo -e "${BLUE}  OpenCode DevTools - Startup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}No .env file found. Creating from .env.example...${NC}"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}Created .env file. Please edit it and run again!${NC}"
        exit 1
    else
        echo -e "${RED}Error: .env.example not found!${NC}"
        exit 1
    fi
fi

# Parse arguments
PROFILE="${1:-full}"
shift || true

case "$PROFILE" in
    full)
        echo -e "${GREEN}Starting full stack...${NC}"
        docker compose --profile full up -d "$@"
        ;;
    light)
        echo -e "${GREEN}Starting light stack (base services only)...${NC}"
        docker compose up -d "$@"
        ;;
    search)
        echo -e "${GREEN}Starting search stack (SearXNG + Valkey)...${NC}"
        docker compose --profile search up -d "$@"
        ;;
    ai|llm)
        echo -e "${GREEN}Starting AI/LLM stack (Ollama + LiteLLM + WebUI)...${NC}"
        docker compose --profile ai up -d "$@"
        ;;
    workflow)
        echo -e "${GREEN}Starting workflow stack (n8n)...${NC}"
        docker compose --profile workflow up -d "$@"
        ;;
    vector)
        echo -e "${GREEN}Starting vector stack (Qdrant)...${NC}"
        docker compose --profile vector up -d "$@"
        ;;
    db|database)
        echo -e "${GREEN}Starting database stack (PostgreSQL)...${NC}"
        docker compose --profile database up -d "$@"
        ;;
    searxng)
        echo -e "${GREEN}Starting SearXNG...${NC}"
        docker compose up -d searxng valkey
        ;;
    ollama)
        echo -e "${GREEN}Starting Ollama...${NC}"
        docker compose up -d ollama
        ;;
    litellm)
        echo -e "${GREEN}Starting LiteLLM...${NC}"
        docker compose up -d litellm
        ;;
    openwebui|webui)
        echo -e "${GREEN}Starting Open WebUI...${NC}"
        docker compose up -d open-webui
        ;;
    n8n)
        echo -e "${GREEN}Starting n8n...${NC}"
        docker compose up -d n8n
        ;;
    qdrant)
        echo -e "${GREEN}Starting Qdrant...${NC}"
        docker compose up -d qdrant
        ;;
    all)
        echo -e "${GREEN}Starting all services...${NC}"
        docker compose up -d "$@"
        ;;
    *)
        echo -e "${YELLOW}Unknown profile: $PROFILE${NC}"
        echo ""
        echo "Usage: $0 [profile] [service...]"
        echo ""
        echo "Profiles:"
        echo "  full      - Start all services (default)"
        echo "  light     - Start base services only"
        echo "  search    - SearXNG + Valkey"
        echo "  ai/llm   - Ollama + LiteLLM + WebUI"
        echo "  workflow  - n8n"
        echo "  vector    - Qdrant"
        echo "  database  - PostgreSQL"
        echo ""
        echo "Services:"
        echo "  searxng   - Start SearXNG only"
        echo "  ollama    - Start Ollama only"
        echo "  litellm   - Start LiteLLM only"
        echo "  openwebui - Start Open WebUI only"
        echo "  n8n       - Start n8n only"
        echo "  qdrant    - Start Qdrant only"
        echo "  all       - Start all services"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}DevTools started successfully!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Services:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Access points:"
echo -e "  ${GREEN}SearXNG${NC}:      http://localhost:${SEARXNG_PORT:-8080}"
echo -e "  ${GREEN}Open WebUI${NC}:   http://localhost:${OPEN_WEBUI_PORT:-3000}"
echo -e "  ${GREEN}LiteLLM${NC}:      http://localhost:${LITELLM_PORT:-4000}"
echo -e "  ${GREEN}n8n${NC}:          http://localhost:${N8N_PORT:-5678}"
echo -e "  ${GREEN}Qdrant${NC}:      http://localhost:${QDRANT_PORT:-6333}"
echo ""
