# OpenCode DevTools - Makefile
# Usage: make <target>

.PHONY: help up down restart logs ps pull clean status health

# Colors
GREEN := $(shell tput setaf 2 2>/dev/null || echo "")
YELLOW := $(shell tput setaf 3 2>/dev/null || echo "")
BLUE := $(shell tput setaf 4 2>/dev/null || echo "")
RESET := $(shell tput sgr0 2>/dev/null || echo "")

help:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(RESET)"
	@echo "$(BLUE)  OpenCode DevTools - Available Commands$(RESET)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(GREEN)Startup:${RESET}"
	@echo "  make up              - Start full stack"
	@echo "  make up-light       - Start base services only"
	@echo "  make up-search      - Start search stack (SearXNG)"
	@echo "  make up-ai          - Start AI/LLM stack"
	@echo "  make up-workflow    - Start n8n workflow"
	@echo "  make up-vector      - Start Qdrant vector DB"
	@echo ""
	@echo "$(GREEN)Management:${RESET}"
	@echo "  make down           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make pull           - Pull latest images"
	@echo "  make ps             - Show running services"
	@echo "  make status         - Show detailed status"
	@echo "  make health         - Check service health"
	@echo ""
	@echo "$(GREEN)Logs:${RESET}"
	@echo "  make logs           - View all logs"
	@echo "  make logs-<service> - View specific service logs"
	@echo ""
	@echo "$(GREEN)Maintenance:${RESET}"
	@echo "  make clean          - Stop and remove all containers and volumes"
	@echo "  make env            - Create .env from template"
	@echo ""
	@echo "$(GREEN)Services:${RESET}"
	@echo "  make searxng        - Start only SearXNG"
	@echo "  make ollama         - Start only Ollama"
	@echo "  make litellm        - Start only LiteLLM"
	@echo "  make webui          - Start only Open WebUI"
	@echo "  make n8n            - Start only n8n"
	@echo "  make qdrant         - Start only Qdrant"
	@echo ""

# Startup targets
up:
	@echo "$(GREEN)Starting full stack...$(RESET)"
	docker compose --profile full up -d

up-light:
	@echo "$(GREEN)Starting light stack...$(RESET)"
	docker compose up -d

up-search:
	@echo "$(GREEN)Starting search stack...$(RESET)"
	docker compose --profile search up -d

up-ai:
	@echo "$(GREEN)Starting AI/LLM stack...$(RESET)"
	docker compose --profile ai up -d

up-workflow:
	@echo "$(GREEN)Starting workflow stack...$(RESET)"
	docker compose --profile workflow up -d

up-vector:
	@echo "$(GREEN)Starting vector stack...$(RESET)"
	docker compose --profile vector up -d

# Individual service targets
searxng:
	@echo "$(GREEN)Starting SearXNG...$(RESET)"
	docker compose up -d searxng valkey

ollama:
	@echo "$(GREEN)Starting Ollama...$(RESET)"
	docker compose up -d ollama

litellm:
	@echo "$(GREEN)Starting LiteLLM...$(RESET)"
	docker compose up -d litellm

webui:
	@echo "$(GREEN)Starting Open WebUI...$(RESET)"
	docker compose up -d open-webui

n8n:
	@echo "$(GREEN)Starting n8n...$(RESET)"
	docker compose up -d n8n

qdrant:
	@echo "$(GREEN)Starting Qdrant...$(RESET)"
	docker compose up -d qdrant

# Management targets
down:
	@echo "$(YELLOW)Stopping all services...$(RESET)"
	docker compose down

restart:
	@echo "$(YELLOW)Restarting all services...$(RESET)"
	docker compose restart

pull:
	@echo "$(YELLOW)Pulling latest images...$(RESET)"
	docker compose pull

ps:
	@docker compose ps

status:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(RESET)"
	@echo "$(BLUE)  DevTools Status$(RESET)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(RESET)"
	docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

health:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(RESET)"
	@echo "$(BLUE)  Health Check$(RESET)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(GREEN)SearXNG:${RESET}"
	@curl -s http://localhost:8080/healthz 2>/dev/null | jq -r '.version // "DOWN"' || echo "  DOWN"
	@echo ""
	@echo "$(GREEN)LiteLLM:${RESET)"
	@curl -s http://localhost:4000/health 2>/dev/null | jq -r '.status // "DOWN"' || echo "  DOWN"
	@echo ""
	@echo "$(GREEN)Open WebUI:${RESET}"
	@curl -s http://localhost:3000/ 2>/dev/null | grep -q "Open WebUI" && echo "  UP" || echo "  DOWN"
	@echo ""
	@echo "$(GREEN)n8n:${RESET)"
	@curl -s http://localhost:5678/healthz 2>/dev/null | jq -r '.status // "DOWN"' || echo "  DOWN"
	@echo ""
	@echo "$(GREEN)Qdrant:${RESET)"
	@curl -s http://localhost:6333/health 2>/dev/null | jq -r '.status // "DOWN"' || echo "  DOWN"

# Logs targets
logs:
	docker compose logs -f

logs-searxng:
	docker compose logs -f searxng

logs-ollama:
	docker compose logs -f ollama

logs-litellm:
	docker compose logs -f litellm

logs-webui:
	docker compose logs -f open-webui

logs-n8n:
	docker compose logs -f n8n

logs-qdrant:
	docker compose logs -f qdrant

# Maintenance targets
clean:
	@echo "$(RED)WARNING: This will remove all containers and volumes!$(RESET)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		echo "$(GREEN)All containers and volumes removed.$(RESET)"; \
	else \
		echo "Aborted."; \
	fi

env:
	@if [ -f .env ]; then \
		echo "$(YELLOW).env already exists.$(RESET)"; \
	else \
		cp .env.example .env; \
		echo "$(GREEN).env created from template. Please edit it!$(RESET)"; \
	fi
