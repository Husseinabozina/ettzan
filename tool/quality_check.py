#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'


def fail(message: str) -> None:
    print(f'ERROR: {message}')
    raise SystemExit(1)


def check_balanced(path: Path) -> None:
    text = path.read_text(encoding='utf-8')
    stack: list[tuple[str, int]] = []
    pairs = {')': '(', ']': '[', '}': '{'}
    quote: str | None = None
    escaped = False
    line_comment = False
    block_comment = False
    index = 0

    while index < len(text):
        char = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ''

        if line_comment:
            if char == '\n':
                line_comment = False
            index += 1
            continue
        if block_comment:
            if char == '*' and nxt == '/':
                block_comment = False
                index += 2
            else:
                index += 1
            continue
        if quote is not None:
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == quote:
                quote = None
            index += 1
            continue
        if char == '/' and nxt == '/':
            line_comment = True
            index += 2
            continue
        if char == '/' and nxt == '*':
            block_comment = True
            index += 2
            continue
        if char in {'\'', '"'}:
            quote = char
            index += 1
            continue
        if char in '([{':
            stack.append((char, index))
        elif char in ')]}':
            if not stack or stack[-1][0] != pairs[char]:
                fail(f'Unbalanced delimiter in {path.relative_to(ROOT)} at offset {index}')
            stack.pop()
        index += 1

    if stack:
        fail(f'Unclosed delimiter in {path.relative_to(ROOT)} at offset {stack[-1][1]}')


def main() -> None:
    dart_files = sorted(LIB.rglob('*.dart'))
    if not dart_files:
        fail('No Dart files found')

    for path in dart_files:
        check_balanced(path)
        text = path.read_text(encoding='utf-8')
        for import_path in re.findall(r"import 'package:etzan_life_coaching/([^']+)';", text):
            if not (LIB / import_path).exists():
                fail(f'Missing local import {import_path} referenced by {path.relative_to(ROOT)}')

    translations = ROOT / 'assets' / 'translations'
    ar_path = translations / 'ar.json'
    en_path = translations / 'en.json'
    if not ar_path.exists() or not en_path.exists():
        fail('Missing assets/translations/ar.json or assets/translations/en.json')
    try:
        ar_keys = set(json.loads(ar_path.read_text(encoding='utf-8')).keys())
        en_keys = set(json.loads(en_path.read_text(encoding='utf-8')).keys())
    except json.JSONDecodeError as error:
        fail(f'Invalid translation JSON: {error}')
    if ar_keys != en_keys:
        fail(
            'Translation keys differ. '
            f'Missing in ar: {sorted(en_keys - ar_keys)}; '
            f'missing in en: {sorted(ar_keys - en_keys)}'
        )
    generated_keys = LIB / 'core' / 'localization' / 'generated' / 'locale_keys.g.dart'
    if not generated_keys.exists():
        fail('Missing generated locale keys. Run ./tool/generate_localization.sh')

    public_screens: set[str] = set()
    for path in (LIB / 'features').rglob('*.dart'):
        public_screens.update(re.findall(r'^class ([A-Z][A-Za-z0-9]*Screen)\b', path.read_text(encoding='utf-8'), re.MULTILINE))
    if len(public_screens) != 26:
        fail(f'Expected 26 public screens, found {len(public_screens)}: {sorted(public_screens)}')

    routes_file = (LIB / 'core/navigation/app_routes.dart').read_text(encoding='utf-8')
    route_names = set(re.findall(r'static const (\w+) =', routes_file))
    router_file = (LIB / 'app/app_router.dart').read_text(encoding='utf-8')
    mapped_routes = set(re.findall(r'AppRoutes\.(\w+) =>', router_file))
    if route_names != mapped_routes:
        fail(f'Route mismatch. Missing mappings: {sorted(route_names - mapped_routes)}; unknown mappings: {sorted(mapped_routes - route_names)}')

    all_source = '\n'.join(path.read_text(encoding='utf-8') for path in dart_files)
    if 'TextDirection.rtl' in all_source or 'TextDirection.ltr' in all_source:
        fail('Hardcoded TextDirection found; locale must control direction automatically')

    directional_tokens = ['EdgeInsetsDirectional', 'AlignmentDirectional', 'BorderRadiusDirectional', 'PositionedDirectional']
    missing_directional = [token for token in directional_tokens if token not in all_source]
    if missing_directional:
        fail(f'Missing direction-aware primitives: {missing_directional}')

    print('Etzan quality check passed')
    print(f'- Dart files: {len(dart_files)}')
    print(f'- Public screens: {len(public_screens)}')
    print(f'- Named routes: {len(route_names)}')
    print('- Local imports resolved')
    print('- Delimiters balanced')
    print('- No hardcoded text direction')
    print(f'- Translation keys synchronized: {len(ar_keys)}')


if __name__ == '__main__':
    main()
