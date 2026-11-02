#!/usr/bin/env python3
"""Enforce persistence isolation without an additional development dependency."""
from pathlib import Path
import re

PRODUCT_CONDITION_FILES = {
    Path('App/AppConfiguration.swift'),
    Path('Shared/Preview/NativeDesignReviewFixture.swift'),
}


def product_conditions(text):
    """Find product compilation flags, ignoring comments and string contents."""
    trivia = r'//[^\n]*|/\*.*?\*/|""".*?"""|"(?:\\.|[^"\\])*"'
    code = re.sub(trivia, lambda match: re.sub(r'[^\n]', ' ', match[0]), text, flags=re.S)
    return re.findall(r'^[ \t]*#(?:if|elseif)\b[^\n]*\bONLY(?:BODY|WEIGHTS)\b[^\n]*', code, re.M)


def validate(root):
    violations = []
    for path in root.rglob('*.swift'):
        relative = path.relative_to(root)
        text = path.read_text()
        if relative not in PRODUCT_CONDITION_FILES and product_conditions(text):
            violations.append(f'{relative}: product compilation conditions belong at the app boundary')
        folder = relative.parts[0]
        if folder in ('Domain', 'Features', 'Shared'):
            for pattern in (r'import SwiftData', r'@Query\b', r'\bModelContext\b', r'\bSwiftData\w+Repository\b'):
                if re.search(pattern, text):
                    violations.append(f'{relative}: forbidden dependency {pattern}')
            if folder == 'Domain' and 'import SwiftUI' in text:
                violations.append(f'{relative}: domain imports SwiftUI')
    for product in ('OnlyBody', 'OnlyWeights'):
        for path in (root.parent / 'Products' / product / 'Catalog').glob('*.swift'):
            if re.search(r'import (SwiftData|SwiftUI)|\bModelContext\b', path.read_text()):
                violations.append(f'{path}: catalog contains a framework dependency')
    if violations:
        raise ValueError('\n'.join(violations))


if __name__ == '__main__':
    try:
        validate(Path(__file__).resolve().parents[2] / 'Apps' / 'iOS' / 'Sources')
    except ValueError as error:
        raise SystemExit(str(error)) from error
    print('Architecture boundaries passed.')
