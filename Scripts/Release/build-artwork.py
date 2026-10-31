#!/usr/bin/env python3
"""Assemble the input manifest for the editable Canvas artwork renderer."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
review = root / 'Release/1.0/Review'
artwork = review / 'Artwork'
copy = json.loads((review / 'screenshot-copy.json').read_text())
captures = root / 'Release/Artifacts/2026-10-27-upload/Screenshots'
cards = []
for product, languages in copy.items():
    for language, headlines in languages.items():
        for device, width, height in [('iPhone', 1320, 2868)]:
            for index, (headline, emphasis) in enumerate(headlines, 1):
                sources = sorted((captures / product / device / language / 'Store').glob(f'*-0{index}-*.png'))
                if not sources:
                    continue
                assert len(sources) == 1
                stem = f'{product}-{language}-{device}-{index:02}'
                cards.append({'product': product, 'language': language, 'device': device, 'index': index,
                              'headline': headline + ' ' + emphasis, 'width': width, 'height': height,
                              'file': stem + '.png', 'source': str(sources[0].relative_to(root))})
(artwork / 'manifest.json').write_text(json.dumps(cards, ensure_ascii=False, indent=2) + '\n')
print(f'Built {len(cards)}/60 editable artwork cards.')
