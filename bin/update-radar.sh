#!/usr/bin/env bash
# bin/update-radar.sh
# Human-in-the-loop updater for Skyhook Radar
#
# Usage:
#   ./bin/update-radar.sh          # Check for updates, prompt before upgrading
#   ./bin/update-radar.sh --check  # Check only, no prompt (for CI/cron)

set -euo pipefail

FORMULA="skyhook-io/tap/radar"
DARWIN_NIX="$HOME/.config/nix/hosts/work/darwin.nix"
CHECK_ONLY=false

[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

# ── Helpers ────────────────────────────────────────────────────────────────

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
info() { printf '  \033[34m•\033[0m %s\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
err()  { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; }

# ── Tap ────────────────────────────────────────────────────────────────────

ensure_tap() {
  if ! brew tap | grep -q "skyhook-io/tap"; then
    info "Adding tap skyhook-io/tap..."
    brew tap skyhook-io/tap https://github.com/skyhook-io/homebrew-tap
  fi
}

# ── Version detection ──────────────────────────────────────────────────────

installed_version() {
  brew list --versions radar 2>/dev/null | awk '{print $2}' || echo "not installed"
}

latest_version() {
  brew info "$FORMULA" 2>/dev/null \
    | grep -E "^skyhook-io/tap/radar:" \
    | awk -F': ' '{print $2}' \
    | awk '{print $1}' \
    || echo "unknown"
}

# ── Main ───────────────────────────────────────────────────────────────────

bold "Skyhook Radar — update check"
echo ""

ensure_tap

info "Fetching latest version info..."
brew update --quiet 2>/dev/null || true

CURRENT=$(installed_version)
LATEST=$(latest_version)

info "Installed : ${CURRENT}"
info "Latest    : ${LATEST}"
echo ""

# Nothing to do
if [[ "$CURRENT" == "$LATEST" && "$CURRENT" != "not installed" ]]; then
  ok "Already up to date (${CURRENT})"
  exit 0
fi

# Not installed yet
if [[ "$CURRENT" == "not installed" ]]; then
  warn "Radar is not installed yet."
  if $CHECK_ONLY; then
    info "Run without --check to install."
    exit 1
  fi
  read -r -p "  Install radar ${LATEST}? [y/N] " answer
  if [[ "${answer,,}" == "y" ]]; then
    brew install "$FORMULA"
    ok "Installed radar ${LATEST}"
    echo ""
    info "Remember to update the 'Last reviewed' date in:"
    info "  ${DARWIN_NIX}"
  else
    info "Skipped. Install manually with: brew install ${FORMULA}"
  fi
  exit 0
fi

# Update available
warn "Update available: ${CURRENT} → ${LATEST}"
echo ""

# Show changelog if available
if brew info "$FORMULA" 2>/dev/null | grep -q "github.com"; then
  REPO=$(brew info "$FORMULA" | grep "github.com" | head -1 | awk '{print $1}')
  info "Changelog / releases: ${REPO}/releases"
fi
echo ""

if $CHECK_ONLY; then
  warn "Run without --check to upgrade interactively."
  exit 1
fi

read -r -p "  Upgrade radar ${CURRENT} → ${LATEST}? [y/N] " answer
echo ""

if [[ "${answer,,}" == "y" ]]; then
  brew upgrade "$FORMULA"
  NEW=$(installed_version)
  ok "Upgraded to ${NEW}"
  echo ""
  # Bump the "Last reviewed" date in darwin.nix
  TODAY=$(date +%Y-%m-%d)
  if sed -i '' "s/# Last reviewed: .*/# Last reviewed: ${TODAY}/" "$DARWIN_NIX" 2>/dev/null; then
    ok "Updated 'Last reviewed' date in darwin.nix → ${TODAY}"
  fi
  echo ""
  warn "Rebuild to apply: darwin-rebuild switch --flake ~/.config/nix"
else
  info "Skipped. Upgrade manually with: brew upgrade ${FORMULA}"
  info "Or re-run this script when ready."
fi
