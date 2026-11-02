#!/usr/bin/env python3
"""Validate marketing copy and build localized text exports and a local preview."""
import argparse
import json
from pathlib import Path
import struct

root = Path(__file__).resolve().parents[2]
review = root / 'Assets/Marketing'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--captures', type=Path, default=review / 'Captures')
args = parser.parse_args()
artifacts = args.captures.resolve()
if not artifacts.is_relative_to(review):
    parser.error('Captures must be inside Assets/Marketing so the local preview can load them.')
metadata = json.loads((review / 'metadata.json').read_text())
copy = json.loads((review / 'screenshot-copy.json').read_text())
variants = {(item['product'], item['language']) for item in metadata['localizations']}
assert len(variants) == len(metadata['localizations']), 'Duplicate product/language metadata'
assert variants == {(product, language) for product, languages in copy.items() for language in languages}, 'Metadata and screenshot languages must match'
assert all(len(headlines) == 6 for languages in copy.values() for headlines in languages.values()), 'Each variant needs six screenshot headlines'
expected = len(variants) * 6
checks = []
for item in metadata['localizations']:
    for key, limit in [('name', 30), ('subtitle', 30), ('promotional_text', 170), ('description', 4000)]:
        assert 0 < len(item[key]) <= limit, (item['locale'], item['product'], key)
    assert len(item['keywords'].encode('utf-8')) <= 100
    terms = item['keywords'].split(',')
    assert len(set(terms)) == len(terms)
    assert all(len(term) > 2 and term == term.strip() for term in terms)
    destination = review / 'localizations' / item['locale'] / item['product']
    destination.mkdir(parents=True, exist_ok=True)
    (destination / 'metadata.json').write_text(json.dumps(item, ensure_ascii=False, indent=2) + '\n')
    for key in ['name', 'subtitle', 'keywords', 'promotional_text', 'description']:
        (destination / (key + '.txt')).write_text(item[key] + '\n')
    checks.append({'product': item['product'], 'locale': item['locale'], 'text_limits': 'PASS',
                   'keyword_bytes': len(item['keywords'].encode('utf-8'))})

shots = []
artwork = []
artwork_manifest = review / 'Artwork/manifest.json'
if artwork_manifest.exists():
    for card in json.loads(artwork_manifest.read_text()):
        if card['device'] != 'iPhone':
            continue
        image = review / 'Artwork' / card['file']
        if not image.exists():
            continue
        width, height = struct.unpack('>II', image.read_bytes()[16:24])
        assert (width, height) == (card['width'], card['height'])
        artwork.append({**card, 'path': 'Artwork/' + card['file']})
for manifest in sorted(artifacts.glob('*/iPhone/*/manifest.json')):
    capture = json.loads(manifest.read_text())
    for shot in capture['screenshots']:
        image = manifest.parent / shot['file']
        assert image.exists(), image
        shots.append({'product': capture['product'], 'language': capture['language'],
                      'device': capture['device'], 'kind': shot['file'].split('/')[0],
                      'file': image.name, 'path': image.relative_to(review).as_posix(),
                      'width': shot['width'], 'height': shot['height']})
settings = {}
for line in (root / 'Apps/iOS/Configuration/App.xcconfig').read_text().splitlines():
    if '=' in line and not line.lstrip().startswith('//'):
        key, value = line.split('=', 1)
        settings[key.strip()] = value.strip()
build = {'version': settings['MARKETING_VERSION'], 'number': settings['CURRENT_PROJECT_VERSION']}
data = {'metadata': metadata, 'screenshots': shots, 'artwork': artwork, 'build': build}
serialized = json.dumps(data, ensure_ascii=False).replace('</', '<\\/')
template = (review / 'review-template.html').read_text()
assert template.count('__REVIEW_DATA__') == 1
(review / 'index.html').write_text(template.replace('__REVIEW_DATA__', serialized))
coverage = []
for product in copy:
    for language in copy[product]:
        for device in ['iPhone']:
            count = sum(x['product'] == product and x['language'] == language and x['device'] == device and x['kind'] == 'Store' for x in shots)
            coverage.append({'product': product, 'language': language, 'device': device, 'store_screenshots': count,
                             'status': 'PASS' if count == 6 else 'PENDING'})
verification = {'status': 'LOCAL_PACKAGE_CHECK', 'text_checks': checks, 'screenshot_coverage': coverage,
                'complete_store_screenshots': sum(x['kind'] == 'Store' for x in shots), 'expected_store_screenshots': expected,
                'complete_artwork': len(artwork), 'expected_artwork': expected}
(review / 'verification.json').write_text(json.dumps(verification, ensure_ascii=False, indent=2) + '\n')
print(f"Marketing preview: {len(checks)} localized texts; {verification['complete_store_screenshots']}/{expected} screenshots; {len(artwork)}/{expected} artwork")
