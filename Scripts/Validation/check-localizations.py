#!/usr/bin/env python3
"""Validate translations and stable catalog lookup coverage for both products."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[2]
source = root / 'onlybody/onlybody'
strings = json.loads((source / 'Localizable.xcstrings').read_text())['strings']
languages = {'en', 'uk', 'pl', 'de', 'fr'}
for key, entry in strings.items():
    assert set(entry['localizations']) == languages, key
    original = entry['localizations']['en']['stringUnit']['value']
    def parameters(value):
        matches = re.findall(r'%(?:(\d+)\$)?(lld|@)', value)
        return sorted((int(position) if position else index, kind)
                      for index, (position, kind) in enumerate(matches, 1))
    for language, translation in entry['localizations'].items():
        unit = translation['stringUnit']
        assert unit['state'] == 'translated' and unit['value'].strip(), (key, language)
        assert parameters(unit['value']) == parameters(original), (key, language)
        assert re.findall(r'https://[^)\s]+', original) == re.findall(r'https://[^)\s]+', unit['value']), (key, language)
lookup = (source / 'Domain/Catalog/CatalogLocalization.swift').read_text()
exercise_lookup, label_lookup = lookup.split('private static let labels:')
for product, path in [('OnlyBody', 'Scripts/StoreGenerator/SeedData.json'),
                      ('OnlyWeights', 'Scripts/StoreGenerator/OnlyWeights/SeedData.json')]:
    rows = json.loads((root / path).read_text())
    for row in rows:
        assert f'"{row["name"]}": .' in exercise_lookup, row['name']
        for label in row['equipment'] + row['primaryMuscles'] + row['secondaryMuscles']:
            assert f'"{label}": .' in label_lookup, label
    print(f'{product}: {len(rows)} exercises have translation coverage.')
for symbol in re.findall(r': \.(\w+)', lookup):
    assert symbol in strings, symbol
print(f'{len(strings)} resources complete in {", ".join(sorted(languages))}; parameters and policy links match.')
