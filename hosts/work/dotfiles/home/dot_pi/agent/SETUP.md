# Pi (work)

Packages: web-access, permissions, opencode-go-provider
Gateway: ai-gateway/* uses the Enexis AI Gateway from OpenCode
Default: ai-gateway/gpt-5.6-luna with xhigh thinking; oMLX remains available via `/model`

```bash
pi
```

Auth: Pi reads the SOPS-managed `litellm_gateway_key` directly, independently of OpenCode; the value must be an active LiteLLM virtual key starting with `sk-`
Models: `ai-gateway/*` and `omlx/*` are explicitly approved in `settings.json`; use `/model` or Ctrl+P
Optional web key: ~/.pi/web-search.json

For a one-off request with a temporary override:

```bash
pi --api-key 'sk-...' --model ai-gateway/gpt-5.6-luna
```

The key is not stored in `models.json`; Pi reads the decrypted SOPS runtime file on startup. Restart Pi after changing the secret.

Check gateway discovery:

```bash
pi --list-models ai-gateway
```

If this returns no models, replace the `litellm_gateway_key` SOPS value and run the work Home Manager activation again. The gateway must also accept the model IDs listed in `models.json`.
