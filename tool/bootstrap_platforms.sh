#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed or is not available in PATH." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$ROOT"
cp -R lib test docs design_reference pubspec.yaml analysis_options.yaml README.md .gitignore "$TMP"/

flutter create \
  --project-name etzan_life_coaching \
  --org com.etzan \
  --platforms=android,ios,web,macos,windows,linux \
  .

rm -rf lib test docs design_reference
cp -R "$TMP/lib" "$TMP/test" "$TMP/docs" "$TMP/design_reference" .
cp "$TMP/pubspec.yaml" "$TMP/analysis_options.yaml" "$TMP/README.md" "$TMP/.gitignore" .

flutter pub get

echo "Etzan platform shells created successfully. Run: flutter run"
