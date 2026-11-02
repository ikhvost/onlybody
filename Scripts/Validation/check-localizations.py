#!/usr/bin/env python3
"""Validate shared translations and each product's stable catalog lookup coverage."""
import json
import re
from pathlib import Path


def read_lookup(text, label):
    pairs = re.findall(r'^\s*"([^"\n]+)":\s*\.(\w+)\s*,?$', text, re.M)
    keys = [key for key, _ in pairs]
    if len(keys) != len(set(keys)):
        raise ValueError(f'{label}: duplicate localization keys')
    return dict(pairs)


def validate_exercise_lookup(rows, lookup, strings, product):
    names = {row['name'] for row in rows}
    missing = names - lookup.keys()
    foreign = lookup.keys() - names
    if missing or foreign:
        raise ValueError(f'{product}: missing exercise translations {sorted(missing)}; foreign keys {sorted(foreign)}')
    for symbol in lookup.values():
        if symbol not in strings:
            raise ValueError(f'{product}: missing translation resource {symbol}')


def parameters(value):
    matches = re.findall(r'%(?:(\d+)\$)?(lld|@)', value)
    return sorted((int(position) if position else index, kind)
                  for index, (position, kind) in enumerate(matches, 1))


def validate(root):
    source = root / 'Apps/iOS/Sources'
    strings = json.loads((source / 'Localizable.xcstrings').read_text())['strings']
    languages = {'en', 'uk', 'pl', 'de', 'fr'}
    info_strings = json.loads((source / 'InfoPlist.xcstrings').read_text())['strings']
    assert not strings.keys() & info_strings.keys(), 'Resource keys must be unambiguous across catalogs'
    for key, entry in (strings | info_strings).items():
        assert set(entry['localizations']) == languages, key
        original = entry['localizations']['en']['stringUnit']['value']
        for language, translation in entry['localizations'].items():
            unit = translation['stringUnit']
            assert unit['state'] == 'translated' and unit['value'].strip(), (key, language)
            assert parameters(unit['value']) == parameters(original), (key, language)
            assert re.findall(r'https://[^)\s]+', original) == re.findall(r'https://[^)\s]+', unit['value']), (key, language)
    labels = read_lookup((source / 'Domain/Catalog/CatalogLocalization.swift').read_text(), 'Shared labels')
    for symbol in labels.values():
        assert symbol in strings, symbol
    for product, path in [('OnlyBody', 'Scripts/StoreGenerator/SeedData.json'),
                          ('OnlyWeights', 'Scripts/StoreGenerator/OnlyWeights/SeedData.json')]:
        rows = json.loads((root / path).read_text())
        catalog = root / f'Apps/iOS/Products/{product}/Catalog/ExerciseLocalizationCatalog.swift'
        lookup = read_lookup(catalog.read_text(), product)
        validate_exercise_lookup(rows, lookup, strings, product)
        for row in rows:
            for label in row['equipment'] + row['primaryMuscles'] + row['secondaryMuscles']:
                assert label in labels, (product, label)
        print(f'{product}: {len(rows)} exercises have product-specific translation coverage.')
    print(f'{len(strings) + len(info_strings)} resources complete in {", ".join(sorted(languages))}; parameters and policy links match.')


if __name__ == '__main__':
    try:
        validate(Path(__file__).resolve().parents[2])
    except ValueError as error:
        raise SystemExit(str(error)) from error
