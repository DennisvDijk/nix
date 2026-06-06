#!/usr/bin/env bash

set -euo pipefail

REPO="jundot/omlx"
NIX_FILE="${HOME}/.config/nix/modules/darwin/features/omlx-app.nix"

if [ ! -f "$NIX_FILE" ]; then
    echo "❌ omlx-app.nix not found at $NIX_FILE"
    exit 1
fi

# Extract current pinned version from the nix file
CURRENT_VERSION=$(grep -E '^\s*version\s*=' "$NIX_FILE" | sed -E 's/.*"([^"]+)".*/\1/')
echo "📌 Current pinned version: $CURRENT_VERSION"

# Fetch latest release from GitHub API
echo "🌐 Checking latest release from GitHub..."
LATEST_JSON=$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest")

LATEST_TAG=$(echo "$LATEST_JSON" | grep -m1 '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" = "null" ]; then
    echo "⚠️  Could not determine latest version from GitHub API."
    echo "   Leaving pinned version ${CURRENT_VERSION} in place."
    exit 0
fi

echo "🏷️  Latest upstream version: $LATEST_TAG"

# Check if latest is already pinned
if [ "$LATEST_TAG" = "$CURRENT_VERSION" ]; then
    echo "✅ Already up to date ($CURRENT_VERSION). Nothing to do."
    exit 0
fi

# Find the macOS dmg asset URL for this release
ASSET_URL=$(echo "$LATEST_JSON" | grep -o '"browser_download_url": *"[^"]*sequoia[^"]*\.dmg"' | head -n1 | sed -E 's/.*"(https:\/\/[^"]+)".*/\1/')

if [ -z "$ASSET_URL" ]; then
    echo "⚠️  Latest release ($LATEST_TAG) does not include a macOS Sequoia .dmg asset."
    echo "   Leaving pinned version ${CURRENT_VERSION} in place."
    exit 0
fi

# Prompt user with timeout (default: no change)
echo ""
echo "🔄 A newer version is available: ${LATEST_TAG}"
read -t 15 -p "   Update omlx-app.nix to ${LATEST_TAG}? [y/N] " response || true
echo ""

response="${response:-N}"

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "⏹️  Skipped. Keeping pinned version ${CURRENT_VERSION}."
    exit 0
fi

# Prefetch the new dmg to compute the SRI hash
echo "⬇️  Prefetching ${LATEST_TAG} to compute hash..."
SRI_HASH=$(nix-prefetch-url "$ASSET_URL" 2>/dev/null) || {
    echo "❌ Failed to prefetch $ASSET_URL"
    exit 1
}

# Update the nix file in-place
sed -i.bak \
    -e "s/version = \"[^\"]*\"/version = \"${LATEST_TAG}\"/" \
    -e "s|url = \"https://github.com/jundot/omlx/releases/download/v[^\"]*|url = \"https://github.com/jundot/omlx/releases/download/v${LATEST_TAG}|" \
    -e "s/sha256 = \"[^\"]*\"/sha256 = \"${SRI_HASH}\"/" \
    "$NIX_FILE"

rm -f "${NIX_FILE}.bak"

echo "✅ Updated omlx-app.nix → version ${LATEST_TAG}, hash ${SRI_HASH}"
echo "   Run 'sudo darwin-rebuild switch --flake ~/.config/nix#<host>' to apply."
