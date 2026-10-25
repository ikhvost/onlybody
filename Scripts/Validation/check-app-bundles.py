#!/usr/bin/env python3
"""Check product identity and resource isolation in built app bundles."""
import hashlib
import json
import plistlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
products = Path(sys.argv[1])
icons = []
for product in ('OnlyBody', 'OnlyWeights'):
    bundle = products / f'{product.lower()}.app'
    info = plistlib.loads((bundle / 'Info.plist').read_bytes())
    assert info['CFBundleIdentifier'] == f'ikhvost.{product.lower()}', product
    assert info['CFBundleDisplayName'] == product, product
    assert info['UILaunchStoryboardName'] == 'LaunchScreen', product
    stores = list(bundle.rglob('*.store'))
    assert len(stores) == 1, stores
    expected = ROOT / f'onlybody/Products/{product}/Resources/SeedStore/default.store'
    assert stores[0].read_bytes() == expected.read_bytes(), product
    assert not list(bundle.rglob('*.store-wal')) and not list(bundle.rglob('*.store-shm')), product
    assert not list(bundle.rglob('SeedData.json')), product
    product_icons = sorted(bundle.glob('AppIcon*.png'))
    assert product_icons, product
    icons.append({icon.name: hashlib.sha256(icon.read_bytes()).hexdigest() for icon in product_icons})
    if product == 'OnlyWeights':
        media = ROOT / 'Scripts/ExerciseMedia'
        video_ids = {row['videoID'] for row in json.loads((media / 'onlyweights.json').read_text())}
        binaries = [(bundle / info['CFBundleExecutable']).read_bytes()]
        binaries.extend(path.read_bytes() for path in bundle.rglob('*.dylib'))
        for video_id in video_ids:
            assert any(video_id.encode() in binary for binary in binaries), \
                f'OnlyWeights: missing Release video {video_id}'
        assert not list(bundle.rglob('onlyweights-candidates.json')), 'Review register must not ship'
        print(f'OnlyWeights: all {len(video_ids)} catalog video IDs are present in Release binaries.')
    print(f'{product}: bundle identity, icon, launch screen and isolated seed verified.')
assert icons[0] != icons[1], 'Products must have different icons'
