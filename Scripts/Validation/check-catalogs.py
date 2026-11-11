#!/usr/bin/env python3
"""Verify generated product metadata and exact bundled SQLite content without editing stores."""
import json
import sqlite3
import subprocess
import sys
from pathlib import Path

def validate_catalog_keys(rows, registered, product):
    """Canonical names are persisted keys; the registry is extended explicitly."""
    names = [row['name'] for row in rows]
    if len(names) != len(set(names)) or len(registered) != len(set(registered)):
        raise ValueError(f'{product}: duplicate canonical exercise keys')
    missing = set(registered) - set(names)
    new = set(names) - set(registered)
    if missing:
        raise ValueError(f'{product}: registered keys removed or renamed: {sorted(missing)}')
    if new:
        raise ValueError(f'{product}: unregistered exercise keys: {sorted(new)}')


def validate(ROOT):
    registry = json.loads((ROOT / 'Scripts/StoreGenerator/CatalogKeys.json').read_text())
    for product in ('OnlyBody', 'OnlyWeights'):
        seed = ROOT / 'Scripts/StoreGenerator' / ('SeedData.json' if product == 'OnlyBody' else 'OnlyWeights/SeedData.json')
        catalog = ROOT / f'Apps/iOS/Products/{product}/Catalog'
        rows = json.loads(seed.read_text())
        validate_catalog_keys(rows, registry[product], product)
        subprocess.run([sys.executable, str(ROOT / 'Scripts/StoreGenerator/generate-muscles.py'),
                        '--seed', str(seed), '--output', str(catalog / 'ExerciseMuscleCatalog.swift'), '--check'], check=True)
        media = ROOT / 'Scripts/ExerciseMedia' / ('catalog.json' if product == 'OnlyBody' else 'onlyweights.json')
        subprocess.run([sys.executable, str(ROOT / 'Scripts/ExerciseMedia/generate.py'),
                        '--seed', str(seed), '--catalog', str(media),
                        '--output', str(catalog / 'ExerciseDemonstrationCatalog.swift'), '--check']
                       + (['--allow-missing'] if product == 'OnlyWeights' else []), check=True)
        store = ROOT / f'Apps/iOS/Products/{product}/Resources/SeedStore/default.store'
        with sqlite3.connect(f'{store.as_uri()}?mode=ro&immutable=1', uri=True) as connection:
            actual = connection.execute('SELECT ZNAME, ZPRIMARYMUSCLE FROM ZEXERCISE').fetchall()
            assert sorted(actual) == sorted((row['name'], row['primaryMuscle']) for row in rows), product
            for table in ('ZWORKOUT', 'ZWORKOUTITEM', 'ZSESSION', 'ZSESSIONITEM'):
                assert connection.execute(f'SELECT COUNT(*) FROM {table}').fetchone()[0] == 0, product
        print(f'{product}: {len(rows)} bundled exercises match authoring data.')


if __name__ == '__main__':
    try:
        validate(Path(__file__).resolve().parents[2])
    except ValueError as error:
        raise SystemExit(str(error)) from error
