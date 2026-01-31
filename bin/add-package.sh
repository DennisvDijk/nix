#!/usr/bin/env bash

set -euo pipefail

PACKAGE="$1"
HOME_MANAGER_NIX="$HOME/.config/nix/modules/shared/home-manager.nix"
NIX_DIR="$HOME/.config/nix"
HOST=${NIX_HOST:-personal}

if [ -z "$PACKAGE" ]; then
    echo "❌ Usage: add-package.sh <package-name>"
    echo "Voorbeeld: add-package.sh ripgrep"
    exit 1
fi

if [ ! -f "$HOME_MANAGER_NIX" ]; then
    echo "❌ Configuratiebestand niet gevonden: $HOME_MANAGER_NIX"
    exit 1
fi

if grep -q "$PACKAGE" "$HOME_MANAGER_NIX"; then
    echo "✅ $PACKAGE staat al in home-manager.nix"
    exit 0
else
    echo "➕ $PACKAGE toevoegen aan home-manager.nix"
    echo "⚠️  Let op: voeg '$PACKAGE' handmatig toe aan modules/shared/home-manager.nix"
    echo ""
    echo "📝 Locatie: $HOME_MANAGER_NIX"
    echo ""
    echo "⚡ Home Manager configuratie bijwerken..."
    
    if command -v home-manager > /dev/null 2>&1; then
        home-manager switch --flake "$NIX_DIR#$HOST"
        echo "✅ Home Manager update voltooid"
    else
        echo "⚠️  home-manager commando niet gevonden. Voer handmatig uit:"
        echo "     home-manager switch --flake "$NIX_DIR#$HOST""
    fi
fi