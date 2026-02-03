#!/usr/bin/env bash
#
# edit-secrets.sh - Makkelijk secrets bewerken met sops-nix
#
# Gebruik:
#   edit-secrets.sh                    # Bewerk standaard secrets/example.yaml
#   edit-secrets.sh openclaw           # Bewerk secrets/openclaw.yaml
#   edit-secrets.sh <naam>             # Bewerk secrets/<naam>.yaml
#

set -euo pipefail

NIX_DIR="${HOME}/.config/nix"
SECRETS_DIR="${NIX_DIR}/secrets"

# Bepaal welk secrets bestand te bewerken
SECRET_NAME="${1:-example}"
SECRET_FILE="${SECRETS_DIR}/${SECRET_NAME}.yaml"

# Check of we in de nix directory zitten
if [ ! -d "$SECRETS_DIR" ]; then
    echo "❌ Secrets directory niet gevonden: $SECRETS_DIR"
    echo "💡 Zorg dat je in de ~/.config/nix directory zit of dat deze bestaat"
    exit 1
fi

# Check of sops beschikbaar is
if ! command -v sops &> /dev/null; then
    echo "🔧 SOPS niet gevonden, installeren via nix-shell..."
    echo "⏳ Dit kan even duren de eerste keer..."
fi

echo "🔐 Bewerken: $SECRET_FILE"
echo "💡 Tip: Bewerk je secrets, sla op en exit. SOPS versleutelt automatisch!"
echo ""

# Ga naar de nix directory en run sops
cd "$NIX_DIR"

# Gebruik nix-shell om sops te draaien
if ! nix-shell -p sops --run "sops \"$SECRET_FILE\""; then
    echo ""
    echo "❌ Fout bij het bewerken van secrets"
    echo "💡 Mogelijke oorzaken:"
    echo "   - Je age private key is niet beschikbaar"
    echo "   - De .sops.yaml configuratie is incorrect"
    echo "   - Het bestand bestaat nog niet (maak het eerst aan)"
    exit 1
fi

echo ""
echo "✅ Secrets succesvol bijgewerkt!"
echo "📝 Vergeet niet om te committen:"
echo "   git add ${SECRET_FILE#$NIX_DIR/}"
echo "   git commit -m 'Update ${SECRET_NAME} secrets'"
echo ""
echo "🚀 Deploy de wijzigingen met:"
echo "   home-manager switch --flake ${NIX_DIR}#\${NIX_HOST:-personal}"
