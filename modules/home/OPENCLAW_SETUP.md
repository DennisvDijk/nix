# OpenClaw Nix Setup

Dit is de OpenClaw integratie voor je Nix/Home Manager setup.

## Wat is geconfigureerd

- **Gateway**: Draait op localhost:18789
- **Telegram**: Als communicatie kanaal
- **AI Models**: Anthropic Claude Opus 4.5 (primary), OpenAI GPT-4o (fallback)
- **Plugins**: summarize, peekaboo (screenshots), oracle (web search)
- **Service**: Launchd service op macOS

## Setup Stappen

### 1. Secrets aanmaken

Maak een secrets directory aan:
```bash
mkdir -p ~/.secrets
chmod 700 ~/.secrets
```

### 2. Telegram Bot Token

1. Open Telegram
2. Zoek **@BotFather**
3. Stuur: `/newbot`
4. Geef een naam en username
5. Kopieer de token
6. Sla op in: `~/.secrets/telegram-bot-token`
```bash
echo "123456789:ABCdefGHIjklMNOpqrSTUvwxyz" > ~/.secrets/telegram-bot-token
chmod 600 ~/.secrets/telegram-bot-token
```

### 3. Je Telegram User ID

1. Open Telegram
2. Zoek **@userinfobot**
3. Stuur een bericht
4. Kopieer je ID (bijv. `123456789`)
5. Update `modules/home/openclaw.nix`:
```nix
allowFrom = [ 123456789 ];  # Jouw ID hier
```

### 4. Anthropic API Key

1. Ga naar https://console.anthropic.com
2. Maak een API key aan
3. Sla op in: `~/.secrets/anthropic-api-key`
```bash
echo "sk-ant-..." > ~/.secrets/anthropic-api-key
chmod 600 ~/.secrets/anthropic-api-key
```

### 5. Home Manager rebuild

```bash
cd ~/.config/nix
home-manager switch --flake .#personal
```

### 6. Telegram Pairing

1. Stuur een bericht naar je bot in Telegram
2. Je krijgt een pairing code terug (bijv. `ABC123`)
3. Voer uit:
```bash
openclaw pairing approve telegram ABC123
```

### 7. Testen!

Stuur je bot een bericht:
```
"Hoi! Kun je https://nu.nl ophalen en samenvatten?"
```

## Documentatie Bestanden

De `documents/` directory bevat:
- **AGENTS.md**: Gedragsregels voor de agent
- **SOUL.md**: Identiteit en persoonlijkheid
- **TOOLS.md**: Beschikbare tools en richtlijnen

Deze worden geladen bij het starten van OpenClaw.

## Dagelijks Gebruik

### Status checken
```bash
launchctl print gui/$UID/com.steipete.openclaw.gateway | grep state
```

### Logs bekijken
```bash
tail -f /tmp/openclaw/openclaw-gateway.log
```

### Service herstarten
```bash
launchctl kickstart -k gui/$UID/com.steipete.openclaw.gateway
```

### Home Manager rebuild na wijzigingen
```bash
cd ~/.config/nix
home-manager switch --flake .#personal
```

### Rollback (als er iets misgaat)
```bash
home-manager switch --rollback
```

## Troubleshooting

### "Container is unhealthy"
- Check logs: `tail -50 /tmp/openclaw/openclaw-gateway.log`
- Controleer of secrets bestanden bestaan en leesbaar zijn
- Check of API keys geldig zijn

### "Permission denied"
```bash
chmod 700 ~/.secrets
chmod 600 ~/.secrets/*
```

### Pairing werkt niet
```bash
# Check of service draait
launchctl print gui/$UID/com.steipete.openclaw.gateway

# Check openstaande pairing requests
openclaw pairing list

# Handmatig approven
openclaw pairing approve telegram CODE
```

## Plugins toevoegen

In `modules/home/openclaw.nix`, onder `plugins = [ ]`:

```nix
plugins = [
  { source = "github:openclaw/nix-steipete-tools?dir=tools/summarize"; }
  { source = "github:openclaw/nix-steipete-tools?dir=tools/peekaboo"; }
  { source = "github:openclaw/nix-steipete-tools?dir=tools/oracle"; }
  
  # Extra plugins (uncomment om te activeren):
  # { source = "github:openclaw/nix-steipete-tools?dir=tools/poltergeist"; }  # macOS UI control
  # { source = "github:openclaw/nix-steipete-tools?dir=tools/sag"; }          # Text-to-speech
  # { source = "github:openclaw/nix-steipete-tools?dir=tools/camsnap"; }       # Camera snapshots
  # { source = "github:openclaw/nix-steipete-tools?dir=tools/gogcli"; }        # Google Calendar
  # { source = "github:openclaw/nix-steipete-tools?dir=tools/bird"; }          # Twitter/X
];
```

Na toevoegen:
```bash
home-manager switch --flake .#personal
```

## Configuratie aanpassen

Belangrijke waarden in `modules/home/openclaw.nix`:

- **Telegram user ID**: `allowFrom = [ 123456789 ];`
- **Gateway token**: `token = "openclaw-gateway-token-change-me";`
- **Plugins**: Welke tools zijn ingeschakeld
- **Documents pad**: Waar de markdown bestanden staan

## Support

- OpenClaw docs: https://docs.openclaw.ai
- Nix OpenClaw repo: https://github.com/openclaw/nix-openclaw
- Discord: https://discord.com/channels/1456350064065904867
