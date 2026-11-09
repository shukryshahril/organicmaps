#!/usr/bin/env bash
# Fetch the pinned, optional English voice resources for the personal iOS build.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DESTINATION="$REPO_ROOT/iphone/Maps/Resources/Kokoro"
ARCHIVE_SHA256=0d24bbf80526456bd8640f9f484cd1c333aee8a936e618ac44e619eafb79aec9
TEMP_DIRECTORY="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIRECTORY"' EXIT
curl --fail --location --proto '=https' --tlsv1.2 \
  'https://github.com/Jud/kokoro-coreml/releases/download/models-2026-03-23/kokoro-models.tar.gz' \
  --output "$TEMP_DIRECTORY/models.tar.gz"
printf '%s  %s\n' "$ARCHIVE_SHA256" "$TEMP_DIRECTORY/models.tar.gz" | shasum -a 256 --check
mkdir "$TEMP_DIRECTORY/unpacked"
tar -xzf "$TEMP_DIRECTORY/models.tar.gz" -C "$TEMP_DIRECTORY/unpacked"
mkdir -p "$DESTINATION/voices"
for model in kokoro_frontend.mlmodelc kokoro_backend.mlmodelc; do
  # Replace only this script's known model directories.
  rm -rf "$DESTINATION/$model"
  cp -R "$TEMP_DIRECTORY/unpacked/$model" "$DESTINATION/$model"
done
cp "$TEMP_DIRECTORY/unpacked/voices/af_heart.bin" "$DESTINATION/voices/af_heart.bin"
echo 'Kokoro English resources are ready for the iOS build.'
