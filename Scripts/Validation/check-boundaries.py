#!/usr/bin/env python3
"""Enforce persistence isolation without an additional development dependency."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[2] / 'onlybody' / 'onlybody'
violations = []
for folder in ('Domain', 'Features', 'Shared'):
    for path in (root / folder).rglob('*.swift'):
        text = path.read_text()
        for pattern in (r'import SwiftData', r'@Query\b', r'\bModelContext\b', r'\bSwiftData\w+Repository\b'):
            if re.search(pattern, text):
                violations.append(f'{path.relative_to(root)}: forbidden dependency {pattern}')
        if folder == 'Domain' and 'import SwiftUI' in text:
            violations.append(f'{path.relative_to(root)}: domain imports SwiftUI')
if violations:
    raise SystemExit('\n'.join(violations))
print('Architecture boundaries passed.')
