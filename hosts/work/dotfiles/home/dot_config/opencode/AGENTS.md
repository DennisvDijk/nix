# Enexis AI Platform — Global Agent Context

## Stack
- LiteLLM (AI/MCP gateway) op EKS
- OpenWebUI ("Enexis Chat") frontend
- Langfuse v3 (observability, ClickHouse + pgvector)
- Qdrant (vector storage)
- ArgoCD + Helm + Kargo (GitOps / progressive delivery)
- Azure OpenAI (westeurope) + AWS Bedrock (eu-west-1)
- Entra ID / OIDC (authenticatie voor alle services)

## Coding conventions
- Python: ruff + black + mypy, pytest voor tests
- IaC: Terraform/OpenTofu, yamllint, TerraShark skill verplicht
- Commits: conventional commits (feat/fix/chore/docs/infra)
- Secrets: altijd via ESO of AWS Secrets Manager, nooit in code

## Data residency (kritisch)
- Modellen alleen via EU-region endpoints
- Geen data buiten EU verwerken zonder expliciete goedkeuring
- AWS Bedrock: eu-west-1 of eu-central-1 only

## Memory
Je hebt MemPalace persistent memory.
Bij elke sessiestart: call mempalace_status
Voor vragen over eerder werk: call mempalace_search
Na significante taken: call mempalace_diary_write

## Superpowers
Je hebt Superpowers skills. Check beschikbare skills voor complexe taken.
Gebruik brainstorming skill voor nieuwe features.
Gebruik writing-plans voor implementaties > 2 bestanden.
