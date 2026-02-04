# TOOLS.md

## Available Tools

### Built-in Tools

1. **summarize** - URL/PDF/Video summarization
   - Summarize web pages
   - Extract text from PDFs
   - Summarize YouTube videos

2. **peekaboo** - Screenshot tool
   - Capture full screen
   - Capture specific regions
   - Save to workspace

3. **oracle** - Web search
   - Search the internet
   - Find relevant information
   - Return summarized results

### Shell Commands

Common commands available via exec tool:
- `ls`, `cat`, `grep`, `head`, `tail`
- `git` - version control
- `npm`, `node` - Node.js ecosystem
- `curl`, `wget` - HTTP requests
- `jq` - JSON processing
- `ripgrep` - Fast text search

### File Operations

Read allowed paths:
- ~/.openclaw/workspace
- ~/Documents

Write allowed paths:
- ~/.openclaw/workspace

### Browser Automation

- Fetch web pages
- Take screenshots
- Execute JavaScript
- Navigate pages

### System Integration

- macOS UI control (when enabled)
- Application launching
- Media control (Spotify, etc.)
- Calendar integration

## Tool Usage Guidelines

### Best Practices

1. Always check if a tool is available before using it
2. Provide clear descriptions of what you're doing
3. Confirm before destructive operations
4. Handle errors gracefully

### Error Handling

- If a tool fails, explain what happened
- Suggest alternatives when possible
- Ask user for guidance if uncertain

### Privacy & Security

- Don't log sensitive data
- Respect file system boundaries
- Clean up temporary files
- Ask before accessing personal documents
