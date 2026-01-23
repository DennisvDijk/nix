#!/usr/bin/env bash

set -euo pipefail

# Check of een pakket beschikbaar is via nixpkgs en Homebrew (fuzzy + interactief)

if [ -z "$1" ]; then
  read -rp "🔍 Geef de naam van het pakket op: " PACKAGE
else
  PACKAGE="$1"
fi

echo ""
echo "🔎 Zoeken naar '$PACKAGE' (fuzzy match)..."
echo ""

# Nixpkgs zoeken
echo "📦 Nixpkgs:"
if command -v nix > /dev/null 2>&1; then
    if NIX_RESULTS=$(nix search nixpkgs "$PACKAGE" 2>/dev/null | grep -i "$PACKAGE" | head -n 5); then
        echo "$NIX_RESULTS"
    else
        echo "❌ Geen (fuzzy) resultaten gevonden in nixpkgs"
    fi
else
    echo "⚠️  nix commando niet beschikbaar"
fi

echo ""
echo "🍺 Homebrew:"
if command -v brew > /dev/null 2>&1; then
    if BREW_RESULTS=$(brew search "$PACKAGE" 2>/dev/null | grep -i "$PACKAGE" | head -n 5); then
        echo "$BREW_RESULTS"
    else
        echo "❌ Geen (fuzzy) resultaten gevonden in Homebrew"
    fi
else
    echo "⚠️  brew commando niet beschikbaar"
fi

echo ""
echo "💡 Tip: Gebruik 'add-package.sh <pakketnaam>' om een pakket toe te voegen"