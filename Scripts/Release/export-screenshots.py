#!/usr/bin/env python3
"""Export named release screenshots from a successful focused XCTest result."""
import argparse
import json
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('result', type=Path)
parser.add_argument('output', type=Path)
parser.add_argument('--product', choices=['OnlyBody', 'OnlyWeights'], required=True)
parser.add_argument('--device', choices=['iPhone', 'iPad'], required=True)
parser.add_argument('--language', choices=['en', 'uk', 'pl', 'de', 'fr'], default='en')
args = parser.parse_args()
prefix = args.product if args.language == 'en' else args.product + '-' + args.language
summary = json.loads(subprocess.check_output([
    'xcrun', 'xcresulttool', 'get', 'test-results', 'summary', '--path', str(args.result), '--compact'
], text=True))
if summary.get('failedTests', 0) or summary.get('passedTests', 0) == 0:
    raise SystemExit('Only passing test results may be exported as release screenshots')
args.output.mkdir(parents=True, exist_ok=True)
records = []
with tempfile.TemporaryDirectory(prefix='release-screenshots-') as scratch:
    subprocess.run([
        'xcrun', 'xcresulttool', 'export', 'attachments', '--path', str(args.result),
        '--output-path', scratch, '--filter', '*.png'
    ], check=True, stdout=subprocess.DEVNULL)
    for case in json.loads((Path(scratch) / 'manifest.json').read_text()):
        for item in case['attachments']:
            name = item['suggestedHumanReadableName']
            if not name.startswith(prefix + '-'):
                continue
            label = name.split('_0_', 1)[0]
            if not re.fullmatch(re.escape(prefix) + r'-(?:0[1-6]-[a-z-]+|qa-[a-z-]+)', label):
                continue
            if label.endswith('-qa-failure'):
                continue
            source = Path(scratch) / item['exportedFileName']
            data = source.read_bytes()
            if data[:8] != b'\x89PNG\r\n\x1a\n':
                raise SystemExit(f'Not PNG: {source}')
            width, height = struct.unpack('>II', data[16:24])
            qa = '-qa-' in label
            expected = (1320, 2868) if args.device == 'iPhone' else (2064, 2752)
            if not qa and (width, height) != expected:
                raise SystemExit(f'Unexpected store screenshot size: {label}: {width}x{height}')
            folder = args.output / ('QA' if qa else 'Store')
            folder.mkdir(exist_ok=True)
            target = folder / (label + '.png')
            shutil.copyfile(source, target)
            records.append({'file': str(target.relative_to(args.output)), 'width': width, 'height': height})
if len([r for r in records if r['file'].startswith('Store/')]) != 6:
    raise SystemExit('Expected all six store screenshots')
(args.output / 'manifest.json').write_text(json.dumps({
    'product': args.product, 'language': args.language, 'device': args.device, 'source': str(args.result.resolve()),
    'capture': 'Genuine simulator screenshots, Debug isolated store with demonstration data; no image rescaling',
    'screenshots': records
}, indent=2) + '\n')
print(f'Exported {len(records)} images for {args.product} / {args.device}')
