#!/bin/bash

BREW_NIX="$HOME/.config/nix/modules/darwin/features/homebrew.nix"

echo "📦 Homebrew packages synchroniseren..."
echo "⚠️  Let op: Dit script toont de geïnstalleerde packages."
echo "         Gedeelde casks/brews: modules/darwin/features/homebrew.nix"
echo "         Host-specifiek: hosts/<host>/darwin.nix"
echo ""

# Haal alle geïnstalleerde brews en casks op
echo "🍺 Geïnstalleerde formulas:"
brew list --formula

echo ""
echo "📦 Geïnstalleerde casks:"
brew list --cask

echo ""
echo "✅ Voeg de gewenste packages toe aan: $BREW_NIX"
echo "   of aan hosts/<host>/darwin.nix voor één machine."