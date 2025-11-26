#!/usr/bin/env bash
#
# shellkit.bootstrap.sh – bezpečné inicializační skriptování

set -euo pipefail

# --- Nastavení prostředí ---
export SHELLKIT_HOME="${SHELLKIT_HOME:-$HOME/.shellkit}"
export PATH="$SHELLKIT_HOME/bin:$PATH"

# --- Kontrola závislostí ---
for dep in git curl jq gpg sha256sum; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "❌ Missing dependency: $dep"
    exit 1
  fi
done

# --- Stažení/aktualizace shellkit ---
if [ ! -d "$SHELLKIT_HOME" ]; then
  echo "📦 Installing shellkit..."
  git clone https://github.com/shellkit/shellkit "$SHELLKIT_HOME"
else
  echo "🔄 Updating shellkit..."
  git -C "$SHELLKIT_HOME" pull --ff-only
fi

# --- Ověření GPG podpisu ---
echo "🔐 Verifying GPG signature..."
git -C "$SHELLKIT_HOME" verify-commit HEAD || {
  echo "❌ GPG verification failed!"
  exit 1
}

# --- Ověření checksumy ---
echo "🔐 Verifying checksums..."
if [ -f "$SHELLKIT_HOME/CHECKSUMS.sha256" ]; then
  sha256sum -c "$SHELLKIT_HOME/CHECKSUMS.sha256" || {
    echo "❌ Checksum verification failed!"
    exit 1
  }
fi

# --- Aktivace ---
source "$SHELLKIT_HOME/lib/shellkit.sh"

echo "✅ Shellkit bootstrapped securely at $SHELLKIT_HOME"