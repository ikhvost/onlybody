#!/usr/bin/env python3
"""Assemble the input manifest for the editable Canvas artwork renderer."""
import argparse
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
review = root / 'Assets/Marketing'
artwork = review / 'Artwork'
copy = json.loads((review / 'screenshot-copy.json').read_text())
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--captures', type=Path, default=review / 'Captures')
args = parser.parse_args()
captures = args.captures.resolve()
if not captures.is_relative_to(review):
    parser.error('Captures must be inside Assets/Marketing so the local renderer can load them.')
cards = []
expected = 0
for product, languages in copy.items():
    for language, headlines in languages.items():
        expected += len(headlines)
        for device, width, height in [('iPhone', 1320, 2868)]:
            for index, (headline, emphasis) in enumerate(headlines, 1):
                sources = sorted((captures / product / device / language / 'Store').glob(f'*-0{index}-*.png'))
                if not sources:
                    continue
                assert len(sources) == 1
                stem = f'{product}-{language}-{device}-{index:02}'
                cards.append({'product': product, 'language': language, 'device': device, 'index': index,
                              'headline': headline + ' ' + emphasis, 'width': width, 'height': height,
                              'file': stem + '.png', 'source': sources[0].relative_to(review).as_posix()})
(artwork / 'manifest.json').write_text(json.dumps(cards, ensure_ascii=False, indent=2) + '\n')
print(f'Built {len(cards)}/{expected} editable artwork cards.')
if len(cards) < expected:
    print(f'Missing source screenshots: {expected - len(cards)}. Add captures under {captures}.')
