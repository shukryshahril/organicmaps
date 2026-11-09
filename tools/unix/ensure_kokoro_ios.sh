#!/usr/bin/env bash
# Xcode build step: fetch the Kokoro voice resources once if they are missing.
# Without network the build continues and the app simply offers no Kokoro voice.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
KOKORO="$REPO_ROOT/iphone/Maps/Resources/Kokoro"
REQUIRED=(
  "$KOKORO/kokoro_frontend.mlmodelc/weights/weight.bin"
  "$KOKORO/kokoro_backend.mlmodelc/weights/weight.bin"
  "$KOKORO/voices/af_heart.bin"
)
for file in "${REQUIRED[@]}"; do
  if [ ! -s "$file" ]; then
    echo "Kokoro voice resources missing, downloading them once."
    if ! "$REPO_ROOT/tools/unix/setup_kokoro_ios.sh"; then
      # The folder is a bundled resource, so it must exist even when empty.
      mkdir -p "$KOKORO"
      echo "warning: Could not download the Kokoro voice; this build will not include it."
    fi
    exit 0
  fi
done
