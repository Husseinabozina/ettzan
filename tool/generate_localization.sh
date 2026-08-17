#!/usr/bin/env bash
set -euo pipefail

# Regenerate typed keys after editing assets/translations/ar.json or en.json.
dart run easy_localization:generate \
  -S assets/translations \
  -O lib/core/localization/generated \
  -f keys \
  -o locale_keys.g.dart

# Normalize codegen whitespace artifacts (double space after `class`).
sed -i '' 's/abstract class  LocaleKeys/abstract class LocaleKeys/' \
  lib/core/localization/generated/locale_keys.g.dart
dart format lib/core/localization/generated/locale_keys.g.dart >/dev/null

# Reserved for future generated code (Freezed, JSON serialization, etc.).
dart run build_runner build --delete-conflicting-outputs
