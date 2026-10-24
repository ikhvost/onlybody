#!/usr/bin/env python3
"""Verify generated product metadata and exact bundled SQLite content without editing stores."""
import json
import sqlite3
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
for product in ('OnlyBody', 'OnlyWeights'):
    seed = ROOT / 'Scripts/StoreGenerator' / ('SeedData.json' if product == 'OnlyBody' else 'OnlyWeights/SeedData.json')
    catalog = ROOT / f'onlybody/Products/{product}/Catalog'
    rows = json.loads(seed.read_text())
    for script, output in [('generate-difficulties.py', 'ExerciseDifficultyCatalog.swift'),
                           ('generate-muscles.py', 'ExerciseMuscleCatalog.swift')]:
        subprocess.run([sys.executable, str(ROOT / 'Scripts/StoreGenerator' / script),
                        '--seed', str(seed), '--output', str(catalog / output), '--check'], check=True)
    media = ROOT / 'Scripts/ExerciseMedia' / ('catalog.json' if product == 'OnlyBody' else 'onlyweights.json')
    subprocess.run([sys.executable, str(ROOT / 'Scripts/ExerciseMedia/generate.py'),
                    '--seed', str(seed), '--catalog', str(media),
                    '--output', str(catalog / 'ExerciseDemonstrationCatalog.swift'), '--check']
                   + (['--allow-missing'] if product == 'OnlyWeights' else []), check=True)
    store = ROOT / f'onlybody/Products/{product}/Resources/SeedStore/default.store'
    with sqlite3.connect(f'{store.as_uri()}?mode=ro&immutable=1', uri=True) as connection:
        actual = connection.execute('SELECT ZNAME, ZPRIMARYMUSCLE FROM ZEXERCISE').fetchall()
        assert sorted(actual) == sorted((row['name'], row['primaryMuscle']) for row in rows), product
        for table in ('ZWORKOUT', 'ZWORKOUTITEM', 'ZSESSION', 'ZSESSIONITEM'):
            assert connection.execute(f'SELECT COUNT(*) FROM {table}').fetchone()[0] == 0, product
    print(f'{product}: {len(rows)} bundled exercises match authoring data.')
