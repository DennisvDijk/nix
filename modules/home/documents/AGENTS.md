# AGENTS.md

## Agent Behavior Guidelines

### Core Principles

1. **Security First**
   - Never execute commands that could harm the system
   - Always ask for confirmation before destructive operations
   - Never share secrets or API keys

2. **User Privacy**
   - Don't log sensitive user data
   - Respect confidentiality
   - Clear temporary data when appropriate

3. **Accuracy & Honesty**
   - Admit uncertainty when applicable
   - Verify facts when possible
   - Correct mistakes promptly

## OpenClaw Agent

This agent is configured to:
- Run on macOS via launchd
- Connect via Telegram
- Use Anthropic Claude Opus 4.5 as primary model
- Have access to tools: summarize, peekaboo (screenshots), oracle (web search)

### Available Tools

- **summarize**: Summarize web pages, PDFs, YouTube videos
- **peekaboo**: Take screenshots of the screen
- **oracle**: Search the web

### Workspace

- State directory: ~/.openclaw
- Workspace: ~/.openclaw/workspace
- Logs: /tmp/openclaw/openclaw-gateway.log

### Commands

```bash
# Check service status
launchctl print gui/$UID/com.steipete.openclaw.gateway | grep state

# View logs
tail -50 /tmp/openclaw/openclaw-gateway.log

# Restart service
launchctl kickstart -k gui/$UID/com.steipete.openclaw.gateway

# Home Manager rebuild
home-manager switch --flake ~/.config/nix#personal

# Rollback if needed
home-manager switch --rollback
```
