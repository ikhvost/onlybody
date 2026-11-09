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
    assert info.get('CFBundlePackageType') == 'APPL', f'{product}: invalid application package type'
    assert info.get('UIDeviceFamily') == [1], f'{product}: release must target iPhone only'
    assert info['UILaunchStoryboardName'] == 'LaunchScreen', product
    assert info.get('NSSupportsLiveActivities') is True, product
    extensions = list((bundle / 'PlugIns').glob('*.appex'))
    assert [extension.name for extension in extensions] == [f'{product.lower()}WorkoutActivity.appex'], extensions
    extension_info = plistlib.loads((extensions[0] / 'Info.plist').read_bytes())
    assert extension_info['CFBundleIdentifier'] == f'{info["CFBundleIdentifier"]}.WorkoutActivity', product
    assert extension_info.get('CFBundleDisplayName') == product, f'{product}: invalid Live Activity display name'
    assert extension_info['NSExtension']['NSExtensionPointIdentifier'] == 'com.apple.widgetkit-extension', product
    for key in ('CFBundleShortVersionString', 'CFBundleVersion'):
        assert extension_info[key] == info[key], (product, key)
    assert (bundle / 'rest-complete.wav').is_file(), product
    stores = list(bundle.rglob('*.store'))
    assert len(stores) == 1, stores
    expected = ROOT / f'Apps/iOS/Products/{product}/Resources/SeedStore/default.store'
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
    print(f'{product}: bundle identity, icon, launch screen, Live Activity, rest sound and isolated seed verified.')
assert icons[0] != icons[1], 'Products must have different icons'
