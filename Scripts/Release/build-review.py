#!/usr/bin/env python3
"""Build the local, read-only App Store review package without contacting Apple."""
import json
from pathlib import Path
import struct

root = Path(__file__).resolve().parents[2]
review = root / 'Release/1.0/Review'
metadata = json.loads((review / 'metadata.json').read_text())
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
artifacts = root / 'Release/Artifacts/2026-10-27-upload/Screenshots'
for manifest in sorted(artifacts.glob('*/iPhone/*/manifest.json')):
    capture = json.loads(manifest.read_text())
    for shot in capture['screenshots']:
        image = manifest.parent / shot['file']
        assert image.exists(), image
        shots.append({'product': capture['product'], 'language': capture['language'],
                      'device': capture['device'], 'kind': shot['file'].split('/')[0],
                      'file': image.name, 'path': '../../' + str(image.relative_to(root / 'Release')),
                      'width': shot['width'], 'height': shot['height']})
submission = json.loads((root / 'Release/1.0/submission-draft.json').read_text())
privacy = json.loads((root / 'Release/1.0/app-privacy-draft.json').read_text())
settings = {}
for line in (root / 'onlybody/Configuration/App.xcconfig').read_text().splitlines():
    if '=' in line and not line.lstrip().startswith('//'):
        key, value = line.split('=', 1)
        settings[key.strip()] = value.strip()
build = {'version': settings['MARKETING_VERSION'], 'number': settings['CURRENT_PROJECT_VERSION']}
data = {'metadata': metadata, 'screenshots': shots, 'artwork': artwork, 'submission': submission, 'privacy': privacy,
        'build': build,
        'review_notes': 'No account is required and there are no in-app purchases. Workouts and history are stored on the device. To review embedded exercise demonstrations, open Library, choose an exercise, continue through the local notice and allow the system tracking permission. If permission is denied or restricted, the external Watch on YouTube link remains available. Local video consent can be withdrawn in Settings > YouTube. The core workout planner and log remain usable without video. The app uses the official YouTube IFrame Player in WKWebView; it does not offer video downloads.'}
serialized = json.dumps(data, ensure_ascii=False).replace('</', '<\\/')
template = (review / 'review-template.html').read_text()
assert template.count('__REVIEW_DATA__') == 1
(review / 'index.html').write_text(template.replace('__REVIEW_DATA__', serialized))
coverage = []
for product in ['OnlyBody', 'OnlyWeights']:
    for language in ['en', 'uk', 'pl', 'de', 'fr']:
        for device in ['iPhone']:
            count = sum(x['product'] == product and x['language'] == language and x['device'] == device and x['kind'] == 'Store' for x in shots)
            coverage.append({'product': product, 'language': language, 'device': device, 'store_screenshots': count,
                             'status': 'PASS' if count == 6 else 'PENDING'})
verification = {'status': 'LOCAL_PACKAGE_CHECK', 'text_checks': checks, 'screenshot_coverage': coverage,
                'complete_store_screenshots': sum(x['kind'] == 'Store' for x in shots), 'expected_store_screenshots': 60,
                'complete_artwork': len(artwork), 'expected_artwork': 60,
                'submission_status': submission['status'],
                'store_status_scope': 'Last recorded local checkpoint; this generator does not inspect App Store Connect'}
(review / 'verification.json').write_text(json.dumps(verification, ensure_ascii=False, indent=2) + '\n')
print(f"Review package: {len(checks)} localized texts; {verification['complete_store_screenshots']}/60 screenshots; {len(artwork)}/60 artwork")
