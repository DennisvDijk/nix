#!/bin/bash

DARWIN_NIX="$HOME/.config/nix/modules/shared/darwin.nix"

echo "📦 Homebrew packages synchroniseren..."
echo "⚠️  Let op: Dit script toont de geïnstalleerde packages."
echo "         Voeg ze handmatig toe aan modules/shared/darwin.nix"
echo ""

# Haal alle geïnstalleerde brews en casks op
echo "🍺 Geïnstalleerde formulas:"
brew list --formula

echo ""
echo "📦 Geïnstalleerde casks:"
brew list --cask

echo ""
echo "✅ Voeg de gewenste packages toe aan: $DARWIN_NIX"