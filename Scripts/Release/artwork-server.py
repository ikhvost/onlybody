#!/usr/bin/env python3
"""Loopback-only preview server; accepts named PNG exports from the local artwork renderer."""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import re
import struct

root = Path(__file__).resolve().parents[2] / 'Release'
output = root / '1.0/Review/Artwork'


class ArtworkHandler(SimpleHTTPRequestHandler):
    def do_POST(self):
        name = self.path.removeprefix('/export/')
        if not self.path.startswith('/export/') or not re.fullmatch(r'Only(?:Body|Weights)-(?:en|uk|pl|de|fr)-(?:iPhone-0[1-6]|Header|Search)\.png', name):
            self.send_error(400)
            return
        length = int(self.headers.get('Content-Length', '0'))
        if not 0 < length < 20_000_000:
            self.send_error(413)
            return
        data = self.rfile.read(length)
        placement = name.removesuffix('.png').split('-')[-1]
        expected = {'Header': (3840, 1646), 'Search': (1920, 1280)}.get(placement, (1320, 2868))
        if data[:8] != b'\x89PNG\r\n\x1a\n' or struct.unpack('>II', data[16:24]) != expected:
            self.send_error(400)
            return
        destination = output / 'Creative' if placement in {'Header', 'Search'} else output
        destination.mkdir(parents=True, exist_ok=True)
        (destination / name).write_bytes(data)
        self.send_response(201)
        self.end_headers()
        self.wfile.write(b'saved')


parser = argparse.ArgumentParser()
parser.add_argument('--port', type=int, default=8766)
args = parser.parse_args()
ThreadingHTTPServer(('127.0.0.1', args.port), partial(ArtworkHandler, directory=str(root))).serve_forever()
