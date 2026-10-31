#!/usr/bin/env python3
"""Verify and package the current iPhone artwork and localized App Store draft fields."""
import hashlib
import json
from pathlib import Path
import struct
import zipfile

root = Path(__file__).resolve().parents[2]
review = root / 'Release/1.0/Review'
artwork = review / 'Artwork'
cards = json.loads((artwork / 'manifest.json').read_text())
assert len(cards) == 60
checks = []
archive = review / 'app-store-iphone-review.zip'
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED) as package:
    for card in cards:
        assert card['device'] == 'iPhone'
        path = artwork / card['file']
        data = path.read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n'
        assert struct.unpack('>II', data[16:24]) == (1320, 2868)
        assert data[25] == 2, 'Artwork must be opaque RGB'
        source = root / card['source']
        check = {'file': card['file'], 'sha256': hashlib.sha256(data).hexdigest(),
                 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'bytes': len(data)}
        checks.append(check)
        package.write(path, f"{card['product']}/{card['language']}/screenshots/{card['file']}")
    for path in sorted((review / 'localizations').rglob('*')):
        if path.is_file():
            package.write(path, 'metadata/' + str(path.relative_to(review / 'localizations')))
    package.write(review / 'screenshot-copy.json', 'screenshot-copy.json')
    package.writestr('README.txt', 'Owner-review drafts, not submitted.\n60 iPhone PNGs at 1320 x 2868.\n'
                    'Two products, five languages, six feature cards each.\n'
                    'Real simulator screens with fictional demonstration history.\n'
                    'Marketing uploaded with owner authorization. See the dated store audit for remaining release blockers.\n')
verification = {'count': len(checks), 'dimensions': '1320x2868', 'format': 'PNG RGB opaque', 'files': checks}
(artwork / 'export-verification.json').write_text(json.dumps(verification, indent=2) + '\n')
print(f'Packaged {len(cards)} iPhone cards and ten metadata drafts: {archive}')
